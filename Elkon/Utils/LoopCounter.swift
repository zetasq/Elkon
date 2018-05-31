//
//  LoopCounter.swift
//  AnimatedImageKit-iOS
//
//  Created by Zhu Shengqi on 16/12/2017.
//

import Foundation

public enum LoopCount {
  case infinite
  case finite(Int)
}

public struct LoopCounter {

  private var _countdown: LoopCount
  
  public init(loopCount: LoopCount) {
    self._countdown = loopCount
  }
  
  public mutating func increaseCount() {
    switch _countdown {
    case .infinite:
      break
    case .finite(let value):
      if value > 0 {
        _countdown = .finite(value - 1)
      }
    }
  }
  
  public var finished: Bool {
    switch _countdown {
    case .infinite:
      return false
    case .finite(let value):
      return value <= 0
    }
  }
}
