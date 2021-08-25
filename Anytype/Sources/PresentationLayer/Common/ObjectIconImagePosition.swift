//
//  ObjectIconImagePosition.swift
//  ObjectIconImagePosition
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ObjectIconImagePosition {
    case openedObject
    case dashboardList
    case dashboardProfile
    case dashboardSearch
}

extension ObjectIconImagePosition {
    
    var objectIconImageGuidelineSet: ObjectIconImageGuidelineSet {
        switch self {
        case .openedObject:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicObjectIconImageGuidelineFactory.x96,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x112,
                emojiImageGuideline: EmojiObjectIconImageGuidelineFactory.x80,
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x28
            )
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicObjectIconImageGuidelineFactory.x48,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x48,
                emojiImageGuideline: EmojiObjectIconImageGuidelineFactory.x48,
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x18
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil
            )
        case .dashboardSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicObjectIconImageGuidelineFactory.x48,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x48,
                emojiImageGuideline: EmojiObjectIconImageGuidelineFactory.x48,
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x18
            )
        }
    }
    
}
