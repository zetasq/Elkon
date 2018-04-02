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

  private let imageCache: SwiftCache<Data>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty, it will be used to create cache directory")
    self.imageCache = .init(
      cacheName: "cache.\(label).Elkon",
      memoryCacheCostLimit: .max,
      memoryCacheAgeLimit: .greatestFiniteMagnitude,
      diskCacheParentDirectory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!,
      diskCacheByteLimit: 100 * 1024 * 1024,
      diskCacheAgeLimit: 30 * 24 * 60 * 60,
      diskObjectEncoder: { $0 },
      diskObjectDecoder:  { $0 }
    )
  }
  
  public func fetchImageData(at url: URL, completion: @escaping (Data?) -> Void) {
    imageCache.asyncFetchObject(forKey: url.absoluteString) { cachedImageData in
      if let cachedImageData = cachedImageData {
        completion(cachedImageData)
      } else {
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
          
          self.imageCache.asyncSetObject(data, forKey: url.absoluteString)
          completion(data)
        })
        dataTask.resume()
      }
    }
  }
  
}
