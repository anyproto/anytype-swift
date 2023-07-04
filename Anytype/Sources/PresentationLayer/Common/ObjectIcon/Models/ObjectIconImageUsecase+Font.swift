extension ObjectIconImageUsecase {
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
                placeholderImageFont: nil,
                spaceImageFont: nil
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
                placeholderImageFont: nil,
                spaceImageFont: nil
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
                ),
                spaceImageFont: nil
            )
        case .editorAccessorySearch:
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
                ),
                spaceImageFont: nil
            )
        case .editorCalloutBlock:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 20,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 20,
                    weight: .regular
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 20,
                    weight: .regular
                ),
                spaceImageFont: nil
            )
        case .editorSearchExpandedIcons, .homeBottomPanel:
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
                ),
                spaceImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 18,
                    weight: .regular
                )
            )
        case .dashboardList, .inlineSetHeader:
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
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        case .dashboardProfile:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 44,
                    weight: .regular
                ),
                emojiImageFont: nil,
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        case .dashboardSearch, .linkToObject, .widgetList, .fileStorage:
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
                ),
                spaceImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 28,
                    weight: .regular
                )
            )
        case let .mention(type):
            return mentionFontGuidelineSet(for: type)
        case .setRow, .setCollection, .featuredRelationsBlock, .widgetTree:
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
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        case .settingsHeader:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 54,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 54,
                    weight: .regular
                ),
                placeholderImageFont: nil,
                spaceImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 54,
                    weight: .regular
                )
            )
        case .settingsSection:
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
                placeholderImageFont: nil,
                spaceImageFont: nil
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
                placeholderImageFont: nil,
                spaceImageFont: nil
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
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        case .subheading, .body:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 13,
                    weight: .regular
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    name: .inter,
                    size: 15,
                    weight: .regular
                ),
                placeholderImageFont: nil,
                spaceImageFont: nil
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
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        }
    }
}
