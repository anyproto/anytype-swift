extension ObjectIconImageUsecase {
    var objectIconImageGuidelineSet: ObjectIconImageGuidelineSet {
        switch self {
        case .openedObject:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x96,
                profileImageGuideline: ProfileIconImageGuideline.x112,
                emojiImageGuideline: EmojiIconImageGuideline.x80,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: StaticImageGuideline.x80,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
        case .linkToObject:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: nil,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: BasicIconImageGuideline.x48,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
        case .templatePreview:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x32,
                profileImageGuideline: ProfileIconImageGuideline.x32,
                emojiImageGuideline: EmojiIconImageGuideline.x32cornerRadius,
                todoImageGuideline: nil,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x32,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
        }
    }
}
