//
//  GeometryExtension.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import CoreGraphics


extension CGPoint {

    /// Creates a frame given another point.
    ///
    /// - Parameter point: other point
    /// - Returns: frame
    public func frame(to point: CGPoint) -> CGRect {
        let rx = min(x, point.x)
        let ry = min(y, point.y)
        let rw = abs(x - point.x)
        let rh = abs(y - point.y)

        return CGRect(x: rx, y: ry, width: rw, height: rh)
    }
    
}

extension CGRect {

    /// Creates a frame given two points.
    ///
    /// - Parameters:
    ///   - point1: point1
    ///   - point2: point2
    /// - Returns: frame
    public static func frame(from point1: CGPoint, to point2: CGPoint) -> CGRect {
        return point1.frame(to: point2)
    }
    
}
