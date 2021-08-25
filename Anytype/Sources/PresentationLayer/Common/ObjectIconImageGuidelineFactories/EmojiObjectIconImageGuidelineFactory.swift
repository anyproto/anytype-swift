//
//  EmojiObjectIconImageGuidelineFactory.swift
//  EmojiObjectIconImageGuidelineFactory
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum EmojiObjectIconImageGuidelineFactory {
    
    static func imageGuideline(for sizeGroup: ObjectIconImagePosition) -> ImageGuideline? {
        switch sizeGroup {
        case .openedObject:
            return Constants.x80
        case .dashboardList:
            return Constants.x48
        case .dashboardProfile:
            return nil
        case .dashboardSearch:
            return Constants.x48
        }
    }
    
}

private extension EmojiObjectIconImageGuidelineFactory {
    
    enum Constants {
        static let x80 = ImageGuideline(
            size: CGSize(width: 80, height: 80),
            cornerRadius: 18,
            backgroundColor: UIColor.grayscaleWhite
        )
        
        static let x48 = ImageGuideline(
            size: CGSize(width: 48, height: 48),
            cornerRadius: 10,
            backgroundColor: UIColor.grayscaleWhite
        )
    }
}

