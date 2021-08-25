//
//  ProfileObjectIconImageGuidelineFactory.swift
//  ProfileObjectIconImageGuidelineFactory
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ProfileObjectIconImageGuidelineFactory {
    
    static let x112 = ImageGuideline(
        size: CGSize(width: 112, height: 112),
        cornerRadius: 112 / 2,
        backgroundColor: UIColor.grayscaleWhite
    )
    
    static let x80 = ImageGuideline(
        size: CGSize(width: 80, height: 80),
        cornerRadius: 80 / 2,
        backgroundColor: UIColor.grayscaleWhite
    )
    
    static let x48 = ImageGuideline(
        size: CGSize(width: 48, height: 48),
        cornerRadius: 48 / 2,
        backgroundColor: UIColor.grayscaleWhite
    )
    
}
