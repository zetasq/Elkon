//
//  ImageManager.swift
//  Elkon
//
//  Created by Zhu Shengqi on 31/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import SwiftCache
import os.log

public final class ImageManager {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageDataManager")
  
  public static let `default` = ImageManager(label: "default")
  
  private let bitmapImageMemoryCache: SwiftMemoryCache<BitmapImage>
  private let imageDataCache: SwiftCache<Data>
  
  private var _urlToDownloadTaskTable: [URL: ImageDownloadTask] = [:]
  private var _tableLock = os_unfair_lock_s()
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty, it will be used to create cache directory")
    
    // TODO: Adjust cost limit and cache limit according to memory size
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
  
  public func fetchBitmapImage(at url: URL, completion: @escaping (BitmapImage?) -> Void) {
    bitmapImageMemoryCache.asyncFetchObject(forKey: url.absoluteString) { cachedBitmapImage in
      if let cachedBitmapImage = cachedBitmapImage {
        completion(cachedBitmapImage)
        return
      }
      
      self.imageDataCache.asyncFetchObject(forKey: url.absoluteString) { cachedImageData in
        if let cachedImageData = cachedImageData {
          if let bitmapImage = cachedImageData.decodeToBitmapImage() {
            self.bitmapImageMemoryCache.asyncSetObject(bitmapImage, forKey: url.absoluteString, cost: bitmapImage.totalByteSize)
            completion(bitmapImage)
          } else {
            completion(nil)
          }
          
          return
        }
        
        os_unfair_lock_lock(&self._tableLock)
        defer {
          os_unfair_lock_unlock(&self._tableLock)
        }
        
        let imageDownloadTask: ImageDownloadTask
        
        if let existingTask = self._urlToDownloadTaskTable[url] {
          imageDownloadTask = existingTask
        } else {
          imageDownloadTask = ImageDownloadTask(url: url)
          self._urlToDownloadTaskTable[url] = imageDownloadTask
          imageDownloadTask.resume()
        }
        
        imageDownloadTask.addFinishHandler { data in
          guard let data = data else {
            completion(nil)
            return
          }
          
          self.imageDataCache.asyncSetObject(data, forKey: url.absoluteString)
          
          if let bitmapImage = data.decodeToBitmapImage() {
            self.bitmapImageMemoryCache.asyncSetObject(bitmapImage, forKey: url.absoluteString, cost: bitmapImage.totalByteSize)
            completion(bitmapImage)
          } else {
            completion(nil)
          }
        }
      }
    }
  }
  
}
