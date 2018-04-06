//
//  ImageDataManager.swift
//  Elkon
//
//  Created by Zhu Shengqi on 31/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import SwiftCache
import os.log

public final class ImageDataManager {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageDataManager")
  
  public static let `default` = ImageDataManager(label: "default")
  
  private let bitmapImageMemoryCache: SwiftMemoryCache<CGImage>
  private let imageDataCache: SwiftCache<Data>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty, it will be used to create cache directory")
    
    self.bitmapImageMemoryCache = .init(
      cacheName: "\(label).predrawnImageCache.com.zetasq.Elkon",
      costLimit: 50 * 1024 * 1024,
      ageLimit: 30 * 24 * 60 * 60
    )
    
    self.imageDataCache = .init(
      cacheName: "\(label).cache.com.zetasq.Elkon",
      memoryCacheCostLimit: .max,
      memoryCacheAgeLimit: .greatestFiniteMagnitude,
      diskCacheParentDirectory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!,
      diskCacheByteLimit: 100 * 1024 * 1024,
      diskCacheAgeLimit: 30 * 24 * 60 * 60,
      diskObjectEncoder: { $0 },
      diskObjectDecoder:  { $0 }
    )
  }
  
  public func fetchPredrawnImage(at url: URL, completion: @escaping (CGImage?) -> Void) {
    bitmapImageMemoryCache.asyncFetchObject(forKey: url.absoluteString) { cachedBitmapImage in
      if let cachedBitmapImage = cachedBitmapImage {
        completion(cachedBitmapImage)
        return
      }
      
      self.imageDataCache.asyncFetchObject(forKey: url.absoluteString) { cachedImageData in
        if let cachedImageData = cachedImageData {
          if let cgImage = cachedImageData.decodeToCGImage() {
            let bitmapImage = cgImage.generateBitmapImage()
            self.bitmapImageMemoryCache.asyncSetObject(bitmapImage, forKey: url.absoluteString, cost: bitmapImage.bytesPerRow * bitmapImage.height)
            completion(bitmapImage)
          } else {
            completion(nil)
          }
          
          return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
          if let error = error {
            os_log("%@", log: ImageDataManager.logger, type: .error, "Transport error occured when downloading data from \(url): \(error)")
            completion(nil)
            return
          }
          
          guard let response = response as? HTTPURLResponse else {
            os_log("%@", log: ImageDataManager.logger, type: .error, "No response when downloading data from \(url)")
            completion(nil)
            return
          }
          
          guard response.statusCode == 200 else {
            os_log("%@", log: ImageDataManager.logger, type: .error, "StatusCode = \(response.statusCode) when downloading data from \(url)")
            completion(nil)
            return
          }
          
          guard let data = data else {
            os_log("%@", log: ImageDataManager.logger, type: .error, "No data returned when downloading data from \(url)")
            completion(nil)
            return
          }
          
          self.imageDataCache.asyncSetObject(data, forKey: url.absoluteString)
          
          if let cgImage = data.decodeToCGImage() {
            let bitmapImage = cgImage.generateBitmapImage()
            self.bitmapImageMemoryCache.asyncSetObject(bitmapImage, forKey: url.absoluteString, cost: bitmapImage.bytesPerRow * bitmapImage.height)
            completion(bitmapImage)
          } else {
            completion(nil)
          }
        })
        dataTask.resume()
      }
    }
  }
  
}
