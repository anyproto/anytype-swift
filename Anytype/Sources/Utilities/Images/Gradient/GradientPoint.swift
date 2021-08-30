//
//  GradientPoint.swift
//  GradientPoint
//
//  Created by Konstantin Mordan on 28.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

struct GradientPoint {
    let start: CGPoint
    let end: CGPoint
}

extension GradientPoint {
    
    var identifier: String {
        "\(GradientPoint.self).\(start.identifier).\(end.identifier)"
    }
    
}

private extension CGPoint {
    
    var identifier: String {
        NSCoder.string(for: self)
    }
    
}
