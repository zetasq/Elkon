//
//  AnimatedImageDisplayDriver.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/31.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal final class AnimatedImageDisplayDriver: NSObject, ImageDisplayDriverProtocol {
  
  internal weak var delegate: ImageDisplayDriverDelegate?
  
  internal let config: ImageDisplayDriverConfig

  private let animatedImage: AnimatedImage
  
  private var currentFrameIndex: Int

  private var _loopCounter: LoopCounter
  
  private var _accumulator: TimeInterval
  
  private var _animationDisplayLink: CADisplayLink?
  
  private var _needsRequestDisplayingWhenImageBecomesAvailable: Bool
  
  private var _lastFetchedImage: CGImage?
  
  internal init(animatedImage: AnimatedImage, config: ImageDisplayDriverConfig) {
    self.config = config
    self.animatedImage = animatedImage
    
    self.currentFrameIndex = 0
    self._loopCounter = .init(loopCount: animatedImage.loopCount)
    self._accumulator = 0
    self._needsRequestDisplayingWhenImageBecomesAvailable = false
  }
  
  deinit {
    _animationDisplayLink?.invalidate()
  }

  internal func startDisplay() {
    guard _animationDisplayLink == nil && !_loopCounter.finished else {
      return
    }
    
    let posterImage = animatedImage.posterImage
    self._lastFetchedImage = posterImage
    animatedImage.prepareImagesAfterPosterImage()
    
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: UIImage(cgImage: posterImage, scale: config.imageScaleFactor, orientation: .up), animated: config.shouldAnimate)
    
    let weakProxy = WeakProxy(target: self)
    _animationDisplayLink = CADisplayLink(target: weakProxy, selector: #selector(self.displayLinkDidRefresh(_:)))
    _animationDisplayLink!.preferredFramesPerSecond = max(1, min(60, Int(1.0 / animatedImage.frameDelayGCD)))
    
    _animationDisplayLink!.add(to: .main, forMode: .commonModes)
    _animationDisplayLink!.isPaused = false
  }

  internal var isAnimating: Bool {
    get {
      guard let displayLink  = _animationDisplayLink else {
        return false
      }
      return !displayLink.isPaused
    }
    set {
      _animationDisplayLink?.isPaused = !newValue
    }
  }
  
  // MARK: - Action Handlers
  @objc
  private func displayLinkDidRefresh(_ displayLink: CADisplayLink) {
    guard !displayLink.isPaused && !_loopCounter.finished else {
      return
    }
    
    let displayLinkFireInterval = displayLink.duration * 60 / TimeInterval(displayLink.preferredFramesPerSecond)
    
    _accumulator += displayLinkFireInterval
    
    if _needsRequestDisplayingWhenImageBecomesAvailable {
      guard let cachedImage = animatedImage.imageCached(at: currentFrameIndex, previousFetchedImage: _lastFetchedImage) else {
        // This means the CPU usage may be high, so we reset the accumulator
        _accumulator = 0
        return
      }
      
      delegate?.imageDisplayDriverRequestDisplayingImage(self, image: UIImage(cgImage: cachedImage, scale: config.imageScaleFactor, orientation: .up), animated: false)

      _needsRequestDisplayingWhenImageBecomesAvailable = false
    }
    
    if _accumulator >= animatedImage.frameDelays[currentFrameIndex] {
      _accumulator = 0
      currentFrameIndex = (currentFrameIndex + 1) % animatedImage.frameCount
      
      if currentFrameIndex == 0 {
        _loopCounter.increaseCount()
        
        if _loopCounter.finished {
          _animationDisplayLink?.invalidate()
          _animationDisplayLink = nil
          return
        }
      }
      
      _needsRequestDisplayingWhenImageBecomesAvailable = true
    }
  }
}
