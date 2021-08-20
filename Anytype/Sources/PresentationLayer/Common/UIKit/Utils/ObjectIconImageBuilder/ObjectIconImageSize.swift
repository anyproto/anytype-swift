//
//  ObjectIconImageSize.swift
//  ObjectIconImageSize
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ObjectIconImageSize {
    case large
    case medium
}

extension ObjectIconImageSize {
    
    var basic: ImageGuideline {
        switch self {
        case .large:
            return ImageGuideline(
                size: CGSize(width: 96, height: 96),
                cornerRadius: 4,
                backgroundColor: UIColor.grayscaleWhite
            )
        case .medium:
            return ImageGuideline(
                size: CGSize(width: 48, height: 48),
                cornerRadius: 2,
                backgroundColor: UIColor.grayscaleWhite
            )
        }
    }
    
    var profile: ImageGuideline {
        switch self {
        case .large:
            return ImageGuideline(
                size: CGSize(width: 112, height: 112),
                cornerRadius: 112 / 2,
                backgroundColor: UIColor.grayscaleWhite
            )
        case .medium:
            return ImageGuideline(
                size: CGSize(width: 48, height: 48),
                cornerRadius: 48 / 2,
                backgroundColor: UIColor.grayscaleWhite
            )
        }
    }
    
    var emoji: ImageGuideline {
        switch self {
        case .large:
            return ImageGuideline(
                size: CGSize(width: 80, height: 80),
                cornerRadius: 18,
                backgroundColor: UIColor.grayscaleWhite
            )
        case .medium:
            return ImageGuideline(
                size: CGSize(width: 48, height: 48),
                cornerRadius: 10,
                backgroundColor: UIColor.grayscaleWhite
            )
        }
    }
}
