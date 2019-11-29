//
//  CGPointExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 24.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import CoreGraphics


public func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
  left = left + right
}
