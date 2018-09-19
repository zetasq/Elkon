//
//  AnimatedImage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

public final class AnimatedImage {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "AnimatedImage")

  public let firstFrame: FrameResult

  public let frameDelayGCD: TimeInterval
  
  // MARK: - Private Properties
  private let _imageSource: AnimatedImageDataSource
  private let _renderConfig: ImageRenderConfig?
  
  private let _imagePreparingQueue = AnimatedImageBackingQueuePool.randomImagePreparingQueue()
  private let _imageAccessingQueue = AnimatedImageBackingQueuePool.randomImageAccessingQueue()
  
  // The following stored properties should be accessed on _imageAccessingQueue
  private var _frameIndexToImageCache: [Int: CGImage] = [:]
  private var _lastRequestedFrameIndex: Int?
  private var _maxCachedFrameCount: Int
  private var _expandCacheSafePivot: CFTimeInterval?
  
  // MARK: - Init & Deinit
  public init?(dataSource: AnimatedImageDataSource, renderConfig: ImageRenderConfig?) {
    guard let firstImage = dataSource.image(at: 0, previousImage: nil, renderConfig: renderConfig) else {
      os_log("%@", log: AnimatedImage.logger, type: .error, "Failed to get first image from dataSource: \(dataSource)")
      return nil
    }
    self.firstFrame = FrameResult(frameIndex: 0, frameImage: firstImage)
    
    let kGCDPrecision: TimeInterval = 2.0 / 0.02
    var scaledGCD = lrint(dataSource.frameDelays[0] * kGCDPrecision)
    for delay in dataSource.frameDelays {
      scaledGCD = GCD(lrint(delay * kGCDPrecision), scaledGCD)
    }
    self.frameDelayGCD = TimeInterval(scaledGCD) / kGCDPrecision
    
    self._imageSource = dataSource
    self._renderConfig = renderConfig
    
    self._frameIndexToImageCache[0] = self.firstFrame.frameImage
    self._maxCachedFrameCount = _imageSource.frameCount

    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarning(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
  }
  
  // MARK: - Public Methods
  public func frameCached(at index: Int, lastFetchedFrame: FrameResult?) -> FrameResult? {
    assert(index < _imageSource.frameCount)
    
    var cachedImage: CGImage? = nil
    var needsPrepareFrames = false
    
    _imageAccessingQueue.sync {
      cachedImage = _frameIndexToImageCache[index]
      
      if _frameIndexToImageCache.count < _imageSource.frameCount {
        let peekCount = max(2, Int(ceil(1 / _imageSource.frameDelays[index])) / 10)
        for i in index..<index+peekCount {
          let validIndex = i % _imageSource.frameCount
          if _frameIndexToImageCache[validIndex] == nil {
            needsPrepareFrames = true
            break
          }
        }
      }
    }
    
    if needsPrepareFrames {
      prepareFrames(from: index, lastFetchedFrame: lastFetchedFrame)
    }
    
    if let image = cachedImage {
      return FrameResult(frameIndex: index, frameImage: image)
    } else {
      return nil
    }
  }
  
  public func prepareFramesFollowingFirst() {
    prepareFrames(from: 0, lastFetchedFrame: nil)
  }
  
  public var totalByteSize: Int {
    return firstFrame.frameImage.bytesPerRow * firstFrame.frameImage.height * _imageSource.frameCount
  }
  
  public var size: CGSize {
    return CGSize(width: firstFrame.frameImage.width, height: firstFrame.frameImage.height)
  }
  
  public var memoryUsage: Int {
    return firstFrame.frameImage.bytesPerRow * firstFrame.frameImage.height * _frameIndexToImageCache.count
  }
  
  public var loopCount: LoopCount {
    return _imageSource.loopCount
  }
  
  public var frameCount: Int {
    return _imageSource.frameCount
  }
  
  public var frameDelays: [Double] {
    return _imageSource.frameDelays
  }
  
  // MARK: - Private Methods
  private func prepareFrames(from index: Int, lastFetchedFrame: FrameResult?) {
    _imageAccessingQueue.async {
      self._lastRequestedFrameIndex = index
    }
    
    _imagePreparingQueue.async { [weak self] in
      guard let `self` = self else {
        return
      }
      
      var currentMaxCachedFrameCount: Int = 1
      self._imageAccessingQueue.sync {
        if self._maxCachedFrameCount < self._imageSource.frameCount {
          if let safePivot = self._expandCacheSafePivot {
            if CACurrentMediaTime() > safePivot {
              self._maxCachedFrameCount += 1
              self._expandCacheSafePivot = CACurrentMediaTime() + CFTimeInterval(10 + arc4random_uniform(10))
            }
          } else {
            self._maxCachedFrameCount += 1
          }
        }
        
        currentMaxCachedFrameCount = self._maxCachedFrameCount
      }
      
      let preferredPrefetchCount = max(1, min(currentMaxCachedFrameCount, Int(ceil(1 / self._imageSource.frameDelays[index]))))
      
      var cacheWindow: [Int: CGImage] = [:]
      if let frame = lastFetchedFrame {
        cacheWindow[frame.frameIndex] = frame.frameImage
      }
      
      self._imageAccessingQueue.sync {
        for i in index..<index+preferredPrefetchCount {
          let validIdx = i % self._imageSource.frameCount
          cacheWindow[validIdx] = self._frameIndexToImageCache[validIdx]
        }
      }
      
      for i in index..<index+preferredPrefetchCount {
        let validIdx = i % self._imageSource.frameCount
        
        guard cacheWindow[validIdx] == nil else {
          continue
        }
        
        if validIdx > 0 && cacheWindow[validIdx - 1] == nil {
          break
        }
        
        guard let image = self._imageSource.image(at: validIdx, previousImage: cacheWindow[validIdx - 1], renderConfig: self._renderConfig) else {
          break
        }
        
        cacheWindow[validIdx] = image
      }
      
      self._imageAccessingQueue.sync {
        for (index, image) in cacheWindow {
          self._frameIndexToImageCache[index] = image
        }
      }
    }   
  }
  
  // MARK: - Notification Handlers
  @objc
  private func didReceiveMemoryWarning(_ notification: Notification) {
    _imageAccessingQueue.async { [weak self] in
      guard let `self` = self else {
        return
      }
      
      self._expandCacheSafePivot = CACurrentMediaTime() + CFTimeInterval(10 + arc4random_uniform(10))
      
      guard self._frameIndexToImageCache.count > 1 else {
        return
      }
      
      self._maxCachedFrameCount = max(1, self._maxCachedFrameCount / 2)
      self.purgeCachedFramesIfNeeded()
    }
  }
  
  /// Must be called from _imageAccessingQueue
  private func purgeCachedFramesIfNeeded() {
    dispatchPrecondition(condition: .onQueue(_imageAccessingQueue))
    
    guard _frameIndexToImageCache.count > _maxCachedFrameCount else {
      return
    }
    
    guard let lastRequestedFrameIndex = _lastRequestedFrameIndex else {
      return
    }
    
    let reservedFrameIndices: IndexSet
    
    let pivotIndex = lastRequestedFrameIndex
    if pivotIndex + self._maxCachedFrameCount > self._imageSource.frameCount {
      let firstPart = IndexSet(integersIn: pivotIndex..<self._imageSource.frameCount)
      let secondPart = IndexSet(integersIn: 0..<(pivotIndex + self._maxCachedFrameCount - self._imageSource.frameCount))
      
      reservedFrameIndices = firstPart.union(secondPart)
    } else {
      reservedFrameIndices = IndexSet(integersIn: pivotIndex..<pivotIndex+self._maxCachedFrameCount)
    }
    
    let redundantIndices = IndexSet(integersIn: 1..<self._imageSource.frameCount).subtracting(reservedFrameIndices)
    
    for i in redundantIndices {
      _frameIndexToImageCache[i] = nil
    }
  }
  
}

