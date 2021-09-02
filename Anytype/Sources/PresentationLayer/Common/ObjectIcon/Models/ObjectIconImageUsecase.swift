//
//  ObjectIconImageUsecase.swift
//  ObjectIconImageUsecase
//
//  Created by Konstantin Mordan on 19.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

//@see https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=123%3A981
enum ObjectIconImageUsecase {
    case openedObject
    case openedObjectNavigationBar
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
        case .openedObjectNavigationBar:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
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
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 48,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 72,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .openedObjectNavigationBar:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 11,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 14,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .dashboardList:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 30,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .dashboardProfile:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 44,
                    weight: .regular
                ),
                emojiImageFont: nil,
                placeholderImageFont: nil
            )
        case .dashboardSearch:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 30,
                    weight: .regular
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
            )
        }
    }
    
}
