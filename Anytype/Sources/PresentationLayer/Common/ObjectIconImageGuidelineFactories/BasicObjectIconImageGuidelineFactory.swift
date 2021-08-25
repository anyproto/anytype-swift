//
//  BasicObjectIconImageGuidelineFactory.swift
//  BasicObjectIconImageGuidelineFactory
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum BasicObjectIconImageGuidelineFactory {
    
    static let x96 = ImageGuideline(
        size: CGSize(width: 96, height: 96),
        cornerRadius: 4,
        backgroundColor: UIColor.grayscaleWhite
    )
    
    static let x48 = ImageGuideline(
        size: CGSize(width: 48, height: 48),
        cornerRadius: 2,
        backgroundColor: UIColor.grayscaleWhite
    )
    
}

