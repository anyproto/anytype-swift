//
//  ImageCornersGuideline.swift
//  Anytype
//
//  Created by Konstantin Mordan on 24.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct ImageCornersGuideline {
    
    let radius: CGFloat
    let backgroundColor: UIColor?
    
}

extension ImageCornersGuideline {
    
    var isOpaque: Bool {
        guard let backgroundColor = backgroundColor else { return false }
        
        return !backgroundColor.isTransparent
    }
    
}

extension ImageCornersGuideline {
    
    var identifier: String {
        "\(ImageCornersGuideline.self).\(radius).\(backgroundColor?.hexString ?? "")"
    }
    
}
