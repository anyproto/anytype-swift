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
        case .linkToObject:
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
        case .templatePreview:
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
        }
    }
}
