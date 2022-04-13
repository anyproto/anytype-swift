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
        case .editorSearch, .editorAccessorySearch, .editorCalloutBlock:
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
        case .editorSearchExpandedIcons:
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
        case .setRow, .featuredRelationsBlock:
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
