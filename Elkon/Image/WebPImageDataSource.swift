//
//  WebPImageDataSource.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/1.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log
import CWebP

internal final class WebPImageDataSource: AnimatedImageDataSource {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "WebPImageDataSource")
  
  internal let loopCount: LoopCount
  
  internal let frameCount: Int
  
  internal let frameDelays: [Double]
  
  private let _rawData: NSData
  
  private var _webpData: WebPData
  
  private let _demuxer: OpaquePointer
  
  private let _canvasSize: CGSize
  
  private let _frameInfos: [WebPFrameInfo]
  
  internal init?(data: Data) {
    self._rawData = data as NSData
    self._webpData = WebPData(bytes: self._rawData.bytes.bindMemory(to: UInt8.self, capacity: self._rawData.length), size: self._rawData.length)
    
    guard let demuxer = WebPDemux(&self._webpData) else {
      return nil
    }
    self._demuxer = demuxer
    
    let canvasSize = CGSize(
      width: CGFloat(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_WIDTH)),
      height: CGFloat(WebPDemuxGetI(demuxer, WEBP_FF_CANVAS_HEIGHT))
    )
    guard canvasSize.width > 0 && canvasSize.height > 0 else {
      WebPDemuxDelete(demuxer)
      return nil
    }
    self._canvasSize = canvasSize
    
    let loopCount = WebPDemuxGetI(demuxer, WEBP_FF_LOOP_COUNT)
    self.loopCount = loopCount > 0 ? .finite(Int(loopCount)) : .infinite
    
    let frameCount = Int(WebPDemuxGetI(demuxer, WEBP_FF_FRAME_COUNT))
    self.frameCount = frameCount
    
    var frameDelays: [Double] = []
    var frameInfos: [WebPFrameInfo] = []
    
    var iterator = WebPIterator()
    
    // 1-based index!!!
    guard WebPDemuxGetFrame(demuxer, 1, &iterator) != 0 else {
      WebPDemuxDelete(_demuxer)
      return nil
    }
    
    defer {
      WebPDemuxReleaseIterator(&iterator)
    }
    
    var i = 0
    repeat {
      frameDelays.append(Double(iterator.duration) / 1000.0)
      
      let frameIndex = i
      
      let frameRect = CGRect(
        x: CGFloat(iterator.x_offset),
        y: canvasSize.height - CGFloat(iterator.y_offset) - CGFloat(iterator.height),
        width: CGFloat(iterator.width),
        height: CGFloat(iterator.height)
      )
      
      let dispostToBackground = iterator.dispose_method == WEBP_MUX_DISPOSE_BACKGROUND
      let blendWithPreviousFrame = iterator.blend_method == WEBP_MUX_BLEND
      
      let hasAlpha = iterator.has_alpha != 0
      
      let frameInfo = WebPFrameInfo(
        canvasSize: canvasSize,
        frameIndex: frameIndex,
        frameRect: frameRect,
        disposeToBackground: dispostToBackground,
        blendWithPreviousFrame: blendWithPreviousFrame,
        hasAlpha: hasAlpha
      )
      
      frameInfos.append(frameInfo)
      
      i += 1
    } while WebPDemuxNextFrame(&iterator) != 0 && i < frameCount
    
    guard frameInfos.count == frameCount else {
      WebPDemuxDelete(_demuxer)
      return nil
    }
    
    self.frameDelays = frameDelays
    self._frameInfos = frameInfos
  }
  
  deinit {
    WebPDemuxDelete(_demuxer)
  }
  
  internal func image(at index: Int, previousImage: CGImage?, renderConfig: ImageRenderConfig?) -> CGImage? {
    var iterator = WebPIterator()
    
    // 1-based index!!!
    guard WebPDemuxGetFrame(_demuxer, Int32(index) + 1, &iterator) != 0 else {
      return nil
    }
    
    defer {
      WebPDemuxReleaseIterator(&iterator)
    }
    
    guard index < _frameInfos.count else {
      return nil
    }
    
    let frameInfo = _frameInfos[index]
    
    let isKeyFrameAtCurrentIndex = isKeyFrame(with: frameInfo)
    guard isKeyFrameAtCurrentIndex || previousImage != nil else {
      return nil
    }
    
    var config = WebPDecoderConfig()
    
    let payload = iterator.fragment.bytes
    let payloadSize = iterator.fragment.size
    
    guard WebPInitDecoderConfig(&config) != 0 && WebPGetFeatures(payload, payloadSize, &config.input) == VP8_STATUS_OK else {
      return nil
    }
    
    let components = config.input.has_alpha != 0 ? 4 : 3
    let bitsPerComponent = 8
    let bitsPerPixel = bitsPerComponent * components
    let bytesPerRow = Int(iterator.width) * components
    
    config.output.colorspace = config.input.has_alpha != 0 ? MODE_rgbA : MODE_RGB
    config.options.use_threads = 1
    
    let decodeStatus = WebPDecode(payload, payloadSize, &config)
    guard decodeStatus == VP8_STATUS_OK else {
      return nil
    }
    
    guard let provider = CGDataProvider(
      dataInfo: nil,
      data: config.output.u.RGBA.rgba,
      size: config.output.u.RGBA.size,
      releaseData: { info, data, size in free(UnsafeMutableRawPointer(mutating: data)) }
      ) else {
        free(config.output.u.RGBA.rgba)
        return nil
    }
    
    let imageBitmapInfo: CGBitmapInfo = config.input.has_alpha != 0 ? [.byteOrder32Big, CGBitmapInfo(rawValue:  CGImageAlphaInfo.premultipliedLast.rawValue)] : CGBitmapInfo(rawValue:  CGImageAlphaInfo.none.rawValue)
    
    let cgImage = CGImage(
      width: Int(iterator.width),
      height: Int(iterator.height),
      bitsPerComponent: bitsPerComponent,
      bitsPerPixel: bitsPerPixel,
      bytesPerRow: bytesPerRow,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: imageBitmapInfo,
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )!
    
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    
    let bitmapSize = _canvasSize.adjustedCanvasSize(for: renderConfig)
    
    let bitmapContext = CGContext(
      data: nil,
      width: Int(bitmapSize.width),
      height: Int(bitmapSize.height),
      bitsPerComponent: 8,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    
    if let renderConfig = renderConfig, renderConfig.needsToClipWithCornerRadius {
      let roundedSize = renderConfig.sizeInPixels
      let roundedRect = CGRect(origin: CGPoint(x: (bitmapSize.width - roundedSize.width) / 2, y: (bitmapSize.height - roundedSize.height) / 2), size: roundedSize)
      
      let bezierPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: renderConfig.cornerRadiusInPixels)
      bitmapContext.addPath(bezierPath.cgPath)
      bitmapContext.clip()
    }
    
    if !isKeyFrameAtCurrentIndex {
      assert(previousImage != nil)
      if let previousImage = previousImage {
        let previousFrameInfo = _frameInfos[index - 1]
        
        bitmapContext.draw(previousImage, in: CGRect(origin: .zero, size: bitmapSize))
        
        if previousFrameInfo.disposeToBackground {
          bitmapContext.clear(previousFrameInfo.adjustedFrameRect(for: renderConfig))
        }
        
        if !frameInfo.blendWithPreviousFrame {
          bitmapContext.clear(frameInfo.adjustedFrameRect(for: renderConfig))
        }
      }
    }
    
    bitmapContext.draw(cgImage, in: frameInfo.adjustedFrameRect(for: renderConfig))
    
    let finalImage = bitmapContext.makeImage()!
    return finalImage
  }
  
  // MARK: - Helper methods
  private func isFullFrame(with frameInfo: WebPFrameInfo) -> Bool {
    return frameInfo.frameRect.origin == .zero && frameInfo.frameRect.size == _canvasSize
  }
  
  private func isKeyFrame(with frameInfo: WebPFrameInfo) -> Bool {
    guard frameInfo.frameIndex > 0 else {
      return true
    }
    
    if isFullFrame(with: frameInfo) && (!frameInfo.hasAlpha || !frameInfo.blendWithPreviousFrame) {
      return true
    } else {
      let previousFrameInfo = _frameInfos[frameInfo.frameIndex - 1]
      return previousFrameInfo.disposeToBackground && (previousFrameInfo.frameIndex == 0 || isFullFrame(with:previousFrameInfo))
    }
  }
  
}
