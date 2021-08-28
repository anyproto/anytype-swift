//
//  GradientColor.swift
//  GradientColor
//
//  Created by Konstantin Mordan on 28.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

struct GradientColor {
    let start: UIColor
    let end: UIColor
}

extension GradientColor {
    
    var identifier: String {
        "\(GradientColor.self).\(start.toHexString).\(end.toHexString)"
    }
    
}
