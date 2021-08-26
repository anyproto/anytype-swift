//
//  ObjectIconImageUsecase.swift
//  ObjectIconImageUsecase
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

enum ObjectIconImageUsecase {
    case openedObject
    case dashboardList
    case dashboardProfile
    case dashboardSearch
}

extension ObjectIconImageUsecase {
    
    var objectIconImageGuidelineSet: ObjectIconImageGuidelineSet {
        switch self {
        case .openedObject:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x96,
                profileImageGuideline: ProfileIconImageGuideline.x112,
                emojiImageGuideline: EmojiIconImageGuideline.x80,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: nil
            )
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileIconImageGuideline.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil
            )
        case .dashboardSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48
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
