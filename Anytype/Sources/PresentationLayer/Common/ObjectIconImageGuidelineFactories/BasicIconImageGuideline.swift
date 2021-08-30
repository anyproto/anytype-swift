//
//  BasicIconImageGuideline.swift
//  BasicIconImageGuideline
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum BasicIconImageGuideline {
    
    static let x96 = ImageGuideline(
        size: CGSize(width: 96, height: 96),
        cornerRadius: 4
    )
    
    static let x48 = ImageGuideline(
        size: CGSize(width: 48, height: 48),
        cornerRadius: 2
    )
    
    static let x18 = ImageGuideline(
        size: CGSize(width: 18, height: 18),
        cornerRadius: 1
    )
    
}

