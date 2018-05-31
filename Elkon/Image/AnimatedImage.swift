//
//  AnimatedImage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class AnimatedImage {
  
  public var totalByteSize: Int {
    return _imageSource.posterImage.bytesPerRow * _imageSource.posterImage.height * _imageSource.frameCount
  }
  
  // MARK: - Public Properties
  public var posterImage: CGImage {
    return _imageSource.posterImage
  }
  
  public var size: CGSize {
    return CGSize(width: _imageSource.posterImage.width, height: _imageSource.posterImage.height)
  }
  
  public var memoryUsage: Int {
    return _imageSource.posterImage.bytesPerRow * _imageSource.posterImage.height * _frameIndexToImageCache.count
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
  
  public private(set) lazy var frameDelayGCD: TimeInterval = {
    let kGCDPrecision: TimeInterval = 2.0 / 0.02
    
    var scaledGCD = lrint(_imageSource.frameDelays[0] * kGCDPrecision)
    
    for delay in _imageSource.frameDelays {
      scaledGCD = GCD(lrint(delay * kGCDPrecision), scaledGCD)
    }
    
    return TimeInterval(scaledGCD) / kGCDPrecision
  }()
  
  // MARK: - Private Properties
  private let _imageSource: AnimatedImageDataSource
  
  private let _queue = DispatchQueue(label: "com.zetasq.Elkon.AnimatedImage.serialQueue")
  
  private var _frameIndexToImageCache: [Int: CGImage] = [:]
  
  private var _backgroundLastRequestedFrameIndex: Int?
  private var _backgroundCachedFrameIndices: IndexSet = IndexSet()
  private var _backgroundMaxCachedFrameCount: Int
  private var _backgroundExpandCacheSafePivot: CFTimeInterval?
  
  // MARK: - Init & Deinit
  public init(dataSource: AnimatedImageDataSource) {
    _imageSource = dataSource
    
    _frameIndexToImageCache[0] = _imageSource.posterImage
    _backgroundCachedFrameIndices.insert(0)
    
    _backgroundMaxCachedFrameCount = _imageSource.frameCount

    NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarning(_:)), name: .UIApplicationDidReceiveMemoryWarning, object: nil)
  }
  
  public convenience init?(data: Data) {
    let imageType = data.imageType
    
    switch imageType {
    case .GIF:
      guard let gifImageSource = GIFImageDataSource(data: data) else {
        return nil
      }
      self.init(dataSource: gifImageSource)
    case .WebP:
    // TODO: Add WebP support
      return nil
    default:
      return nil
    }
  }
  
  // TODO: Init AnimatedImage from local file
//  public convenience init?(fileName: String, bundle: Bundle = .main) {
//    guard let url = bundle.url(forResource: fileName, withExtension: "gif") else {
//      return nil
//    }
//
//    guard let gifData = try? Data(contentsOf: url, options: .mappedIfSafe) else {
//      return nil
//    }
//
//    self.init(gifData: gifData, frameCachePolicy: frameCachePolicy)
//  }
//
  
  
  // MARK: - Public Methods
  public func imageCached(at index: Int) -> CGImage? {
    assert(Thread.isMainThread)
    assert(index < _imageSource.frameCount)
    
    guard index < _imageSource.frameCount else {
      return nil
    }
    
    prepareImages(from: index)
    
    return _frameIndexToImageCache[index]
  }
  
  public func prepareImagesAfterPosterImage() {
    assert(Thread.isMainThread)
    prepareImages(from: 0)
  }
  
  // MARK: - Private Methods
  private func prepareImages(from index: Int) {
    assert(Thread.isMainThread)
    
    _queue.async { [weak self] in
      guard let `self` = self else {
        return
      }
      
      guard self._backgroundLastRequestedFrameIndex != index else {
        return
      }
      
      let adjustedIndex = max(1, index)
      
      guard adjustedIndex < self._imageSource.frameCount else {
        return
      }

      self._backgroundLastRequestedFrameIndex = adjustedIndex
      
      let couldIncreaseThreshold = self._backgroundMaxCachedFrameCount < self._imageSource.frameCount
      
      if couldIncreaseThreshold {
        if let safePivot = self._backgroundExpandCacheSafePivot {
          if CACurrentMediaTime() > safePivot {
            self._backgroundMaxCachedFrameCount += 1
          }
        } else {
          self._backgroundMaxCachedFrameCount += 1
        }
      }
      
      let preferredPrefetchCount = max(1, min(self._backgroundMaxCachedFrameCount, Int(ceil(1 / self._imageSource.frameDelays[adjustedIndex]))))
      
      for i in adjustedIndex..<adjustedIndex+preferredPrefetchCount {
        let validIdx = i % self._imageSource.frameCount
        
        guard !self._backgroundCachedFrameIndices.contains(validIdx) else {
          continue
        }
        
        guard let image = self.generateImage(at: validIdx) else {
          continue
        }
        
        self._backgroundCachedFrameIndices.insert(validIdx)
        
        DispatchQueue.main.async { [validIdx, weak self] in
          guard let `self` = self else {
            return
          }
          
          self._frameIndexToImageCache[validIdx] = image
        }
      }
    }
  }
  
  private func generateImage(at index: Int) -> CGImage? {
    guard let cgImage = _imageSource.image(at: index) else {
      return nil
    }
    
    return cgImage.getPredrawnImage()
  }
  
  // MARK: - Notification Handlers
  @objc
  private func didReceiveMemoryWarning(_ notification: Notification) {
    assert(Thread.isMainThread)
    
    _queue.async { [weak self] in
      guard let `self` = self else {
        return
      }
      
      self._backgroundExpandCacheSafePivot = CACurrentMediaTime() + CFTimeInterval(5 + arc4random_uniform(10))
      
      guard self._backgroundCachedFrameIndices.count > 1 else {
        return
      }
      
      self._backgroundMaxCachedFrameCount = max(1, self._backgroundMaxCachedFrameCount / 2)
      self.purgeCachedFramesIfNeeded()
    }
  }
  
  /// Must be called from the internal queue
  private func purgeCachedFramesIfNeeded() {
    guard _backgroundCachedFrameIndices.count > _backgroundMaxCachedFrameCount else {
      return
    }
    
    guard let lastRequestedFrameIndex = self._backgroundLastRequestedFrameIndex else {
      return
    }
    
    let reservedFrameIndices: IndexSet
    
    let pivotIndex = lastRequestedFrameIndex
    if pivotIndex + self._backgroundMaxCachedFrameCount > self._imageSource.frameCount {
      let firstPart = IndexSet(integersIn: pivotIndex..<self._imageSource.frameCount)
      let secondPart = IndexSet(integersIn: 0..<(pivotIndex + self._backgroundMaxCachedFrameCount - self._imageSource.frameCount))
      
      reservedFrameIndices = firstPart.union(secondPart)
    } else {
      reservedFrameIndices = IndexSet(integersIn: pivotIndex..<pivotIndex+self._backgroundMaxCachedFrameCount)
    }
    
    let redundantIndices = IndexSet(integersIn: 1..<self._imageSource.frameCount).subtracting(reservedFrameIndices)
    
    for i in redundantIndices {
      if self._backgroundCachedFrameIndices.contains(i) {
        self._backgroundCachedFrameIndices.remove(i)
        
        DispatchQueue.main.async { [i, weak self] in
          guard let `self` = self else {
            return
          }
          
          self._frameIndexToImageCache[i] = nil
        }
      }
    }
  }
  
}

