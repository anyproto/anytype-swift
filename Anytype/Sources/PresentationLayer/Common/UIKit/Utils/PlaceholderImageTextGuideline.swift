//
//  PlaceholderImageTextGuideline.swift
//  Anytype
//
//  Created by Konstantin Mordan on 02.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit

struct PlaceholderImageTextGuideline {
    
    let text: String
    let font: UIFont
    let textColor: UIColor
    
    // MARK: - Initializers
    
    init(text: String,
         font: UIFont =  UIFont.body.withSize(72),
         textColor: UIColor = UIColor.grayscaleWhite) {
        self.text = text
        self.font = font
        self.textColor = textColor
    }

    
}

extension PlaceholderImageTextGuideline {
    
    var identifier: String {
        "\(PlaceholderImageTextGuideline.self).\(text).\(font).\(textColor)"
    }
    
}
