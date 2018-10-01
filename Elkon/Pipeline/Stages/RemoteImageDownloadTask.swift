//
//  ImageDownloadTask.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/15.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log
import SwiftCache

internal final class RemoteImageDownloadTask {
  
  internal enum State {
    case ready
    case downloading
    case success(Data)
    case failed
    
    internal var isReady: Bool {
      if case .ready = self {
        return true
      } else {
        return false
      }
    }
    
    internal var isDownloading: Bool {
      if case .downloading = self {
        return true
      } else {
        return false
      }
    }
  }
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageDownloadTask")
  
  private let _url: URL
  
  private let _downloadCache: SwiftDiskCache<Data>
  
  private var _state: State = .ready
  
  private var _finishHandlers: [(Data?) -> Void] = []
  
  private var _lock = os_unfair_lock_s()
  
  internal init(url: URL, downloadCache: SwiftDiskCache<Data>) {
    assert(!url.isFileURL)
    self._url = url
    self._downloadCache = downloadCache
  }
  
  internal func addFinishHandler(_ handler: @escaping (Data?) -> Void) {
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    switch _state {
    case .ready, .downloading:
      _finishHandlers.append(handler)
    case .success(let data):
      handler(data)
    case .failed:
      handler(nil)
    }
  }
  
  internal func resume() {
    os_unfair_lock_lock(&_lock)
    assert(_state.isReady)
    _state = .downloading
    os_unfair_lock_unlock(&_lock)
    
    _downloadCache.asyncFetchObject(forKey: _url.absoluteString) { cachedData in
      if let cachedData = cachedData {
        self._finishFetchingData(cachedData)
        return
      }
      
      let downloadTask = URLSession.shared.downloadTask(with: self._url, completionHandler: { tempURL, response, error in
        if let error = error {
          os_log("%@", log: RemoteImageDownloadTask.logger, type: .error, "Transport error occured when downloading data from \(self._url): \(error)")
          self._finishFetchingData(nil)
          return
        }
        
        guard let response = response as? HTTPURLResponse else {
          os_log("%@", log: RemoteImageDownloadTask.logger, type: .error, "No response when downloading data from \(self._url)")
          self._finishFetchingData(nil)
          return
        }
        
        guard response.statusCode >= 200 && response.statusCode < 300 else {
          os_log("%@", log: RemoteImageDownloadTask.logger, type: .error, "StatusCode = \(response.statusCode) when downloading data from \(self._url)")
          self._finishFetchingData(nil)
          return
        }
        
        guard let tempURL = tempURL,
          let data = self._downloadCache.syncLinkFileURL(tempURL, forKey: self._url.absoluteString) else {
            os_log("%@", log: RemoteImageDownloadTask.logger, type: .error, "No data returned when downloading data from \(self._url)")
            self._finishFetchingData(nil)
            return
        }
        
        self._finishFetchingData(data)
      })

      downloadTask.resume()
    }
  }
  
  private func _finishFetchingData(_ data: Data?) {
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    assert(_state.isDownloading)
    if let data = data {
      _state = .success(data)
    } else {
      _state = .failed
    }
    
    for handler in _finishHandlers {
      handler(data)
    }
  }
  
}
