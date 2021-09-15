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
enum ObjectIconImageUsecase: Equatable {
    case openedObject
    case openedObjectNavigationBar
    
    case editorSearch // slash menu + mention
    
    case dashboardList
    case dashboardProfile
    case dashboardSearch
    case mention(ObjectIconImageMentionType)
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
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .openedObjectNavigationBar:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .editorSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x40,
                profileImageGuideline: ProfileIconImageGuideline.x40,
                emojiImageGuideline: EmojiIconImageGuideline.x40,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: StaticImageGuideline.x24
            )
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileIconImageGuideline.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .dashboardSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: nil
            )
        case let .mention(type):
            return mentionImageGuidelineSet(for: type)
        }
    }
    
    var objectIconImageFontSet: ObjectIconImageFontSet {
        switch self {
        case .openedObject:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 72,
                    weight: .semibold
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 48,
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
        case .editorSearch:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 22,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 24,
                    weight: .regular
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 22,
                    weight: .regular
                )
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
                    size: 28,
                    weight: .regular
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
            )
        case let .mention(type):
            return mentionFontGuidelineSet(for: type)
        }
    }
    
    private func mentionImageGuidelineSet(for type: ObjectIconImageMentionType) -> ObjectIconImageGuidelineSet {
        switch type {
        case .title:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x28,
                profileImageGuideline: ProfileIconImageGuideline.x28,
                emojiImageGuideline: EmojiIconImageGuideline.x28,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .heading:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x24,
                profileImageGuideline: ProfileIconImageGuideline.x24,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .subheading,
             .body:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x20,
                profileImageGuideline: ProfileIconImageGuideline.x20,
                emojiImageGuideline: EmojiIconImageGuideline.x20,
                todoImageGuideline: TodoIconImageGuideline.x20,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        case .callout:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil
            )
        }
    }
    
    private func mentionFontGuidelineSet(for type: ObjectIconImageMentionType) -> ObjectIconImageFontSet {
        switch type {
        case .title:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 19,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .heading:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 16,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 22,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .subheading,
             .body:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 13,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 17,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        case .callout:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 11,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 15,
                    weight: .regular
                ),
                placeholderImageFont: nil
            )
        }
    }
}