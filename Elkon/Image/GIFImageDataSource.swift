//
//  GIFImageDataSource.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/30.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import MobileCoreServices
import os.log

internal final class GIFImageDataSource: AnimatedImageDataSource {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "GIFImageDataSource")
  
  internal let loopCount: LoopCount
  
  internal let frameCount: Int
  
  internal let frameDelays: [Double]
  
  private let _imageSource: CGImageSource
  
  // MARK: - Init & Deinit
  internal init?(data: Data) {
    guard !data.isEmpty else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "Empty GIF data when calling \(#function)")
      return nil
    }
    
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceTypeIdentifierHint: kUTTypeGIF, kCGImageSourceShouldCache: false] as CFDictionary) else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "Failed to create \(CGImageSource.self) when calling \(#function)")
      return nil
    }
    _imageSource = imageSource
    
    guard let sourceType = CGImageSourceGetType(_imageSource), UTTypeConformsTo(sourceType, kUTTypeGIF) else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "Supplied data is not GIF image when calling \(#function)")
      return nil
    }
    
    guard let imageProperties = CGImageSourceCopyProperties(_imageSource, nil) as? [String: Any] else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "Cannot get GIF image properties when calling \(#function)")
      return nil
    }
    
    guard let gifDictionary = imageProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any], let gifLoopCount = gifDictionary[kCGImagePropertyGIFLoopCount as String] as? Int else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "Failed to get GIF image loopCount when calling \(#function)")
      return nil
    }
    self.loopCount = gifLoopCount > 0 ? .finite(gifLoopCount) : .infinite
    
    frameCount = CGImageSourceGetCount(_imageSource)
    guard frameCount > 0 else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "GIF image's frameCount is zero when calling \(#function)")
      return nil
    }
    
    if frameCount == 1 {
      os_log("%@", log: GIFImageDataSource.logger, type: .info, "Get only 1 frame when calling \(#function)")
    }
    
    var tempFrameDelays: [TimeInterval] = []
    
    for i in 0..<frameCount {
      guard let frameProperties = CGImageSourceCopyPropertiesAtIndex(_imageSource, i, nil) as? [String: Any], let gifDictionary = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] else {
        os_log("%@", log: GIFImageDataSource.logger, type: .error, "GIF image is corrupted: cannnot get GIF properties of frame \(i) when calling \(#function)")
        return nil
      }
      
      var delayTime: TimeInterval
      
      if let unclampedDelayTime = gifDictionary[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval {
        delayTime = unclampedDelayTime
      } else if let clampedDelayTime = gifDictionary[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
        delayTime = clampedDelayTime
      } else {
        delayTime = 0.1
      }
      
      if (delayTime < 0.02 - .leastNormalMagnitude) {
        delayTime = 0.1
      }
      
      tempFrameDelays.append(delayTime)
    }
    
    guard frameCount == tempFrameDelays.count else {
      os_log("%@", log: GIFImageDataSource.logger, type: .error, "GIF image is corrupted: some frames are missing when calling \(#function)")
      return nil
    }
    frameDelays = tempFrameDelays
  }
  
  // MARK: - Public Methods
  public func image(at index: Int, previousImage: CGImage?) -> CGImage? {
    return CGImageSourceCreateImageAtIndex(_imageSource, index, nil)
  }
  
}
