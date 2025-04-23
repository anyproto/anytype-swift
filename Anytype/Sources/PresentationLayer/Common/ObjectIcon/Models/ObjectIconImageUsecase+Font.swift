extension ObjectIconImageUsecase {
    var objectIconImageFontSet: ObjectIconImageFontSet {
        switch self {
        case .openedObject:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.semiBold,
                    size: 72
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 48
                ),
                placeholderImageFont: nil,
                spaceImageFont: nil
            )
        case .linkToObject:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 28
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 28
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 28
                ),
                spaceImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 28
                )
            )
        case .templatePreview:
            return ObjectIconImageFontSet(
                profileImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 20
                ),
                emojiImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 20
                ),
                placeholderImageFont: UIKitFontBuilder.uiKitFont(
                    font: FontFamily.Inter.regular,
                    size: 20
                ),
                spaceImageFont: nil
            )
        }
    }
}
