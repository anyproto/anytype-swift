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
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x28,
                placeholderImageGuideline: nil
            )
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicObjectIconImageGuidelineFactory.x48,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x48,
                emojiImageGuideline: EmojiObjectIconImageGuidelineFactory.x48,
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x18,
                placeholderImageGuideline: nil
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil
            )
        case .dashboardSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicObjectIconImageGuidelineFactory.x48,
                profileImageGuideline: ProfileObjectIconImageGuidelineFactory.x48,
                emojiImageGuideline: EmojiObjectIconImageGuidelineFactory.x48,
                todoImageGuideline: TodoObjectIconImageGuidelineFactory.x18,
                placeholderImageGuideline: PlaceholderObjectIconImageGuidelineFactory.x48
            )
        }
    }
    
    var objectIconImageFontSet: ObjectIconImageFontSet {
        switch self {
        case .openedObject:
            return ObjectIconImageFontSet(
                profileImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 48,
                    weight: .regular
                ),
                emojiImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 72,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .dashboardList:
            return ObjectIconImageFontSet(
                profileImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                ),
                emojiImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 30,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .dashboardProfile:
            return ObjectIconImageFontSet(
                profileImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 44,
                    weight: .regular
                ),
                emojiImageFont: nil,
                placeholderImageFont: nil
            )
        case .dashboardSearch:
            return ObjectIconImageFontSet(
                profileImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                ),
                emojiImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 30,
                    weight: .regular
                ),
                placeholderImageFont: AnytypeFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
            )
        }
    }
    
}
