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
  
  internal let driverConfig: ImageDisplayDriverConfig

  private let animatedImage: AnimatedImage
  
  private var currentFrameIndex: Int

  private var _loopCounter: LoopCounter
  
  private var _accumulator: TimeInterval
  
  private var _animationDisplayLink: CADisplayLink?
  
  private var _needsRequestDisplayingWhenImageBecomesAvailable: Bool
  
  private var _lastFetchedFrame: AnimatedImage.FrameResult?
  
  internal init(animatedImage: AnimatedImage, driverConfig: ImageDisplayDriverConfig) {
    self.driverConfig = driverConfig
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
    
    let firstFrame = animatedImage.firstFrame
    self._lastFetchedFrame = firstFrame
    animatedImage.prepareFramesFollowingFirst()
    
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: UIImage(cgImage: firstFrame.frameImage, scale: MAIN_SCREEN_SCALE, orientation: .up), animated: driverConfig.shouldDisplayImageAnimatedly)
    
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
      guard let cachedFrame = animatedImage.frameCached(at: currentFrameIndex, lastFetchedFrame: _lastFetchedFrame) else {
        // This means the CPU usage may be high, so we reset the accumulator
        _accumulator = 0
        return
      }
      
      _lastFetchedFrame = cachedFrame
      
      delegate?.imageDisplayDriverRequestDisplayingImage(self, image: UIImage(cgImage: cachedFrame.frameImage, scale: MAIN_SCREEN_SCALE, orientation: .up), animated: false)

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
