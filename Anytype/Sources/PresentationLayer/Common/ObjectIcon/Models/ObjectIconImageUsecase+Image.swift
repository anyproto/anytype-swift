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
        case .openedObjectNavigationBar:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        case .editorSearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x40,
                profileImageGuideline: ProfileIconImageGuideline.x40,
                emojiImageGuideline: EmojiIconImageGuideline.x40,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: nil, // Use original different icon size
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24,
                spaceImageGuideline: nil
            )
        case .editorSearchExpandedIcons:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x40,
                profileImageGuideline: ProfileIconImageGuideline.x40,
                emojiImageGuideline: EmojiIconImageGuideline.x40,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: nil, // Use original different icon size
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24,
                spaceImageGuideline: nil
            )
        case .editorCalloutBlock:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x20,
                profileImageGuideline: ProfileIconImageGuideline.x20,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x20,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x40,
                staticImageGuideline: StaticImageGuideline.x20,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x20,
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
        case .dashboardList:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        case .dashboardProfile:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: ProfileIconImageGuideline.x80,
                emojiImageGuideline: nil,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
        case .dashboardSearch, .widgetList, .fileStorage:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x48,
                profileImageGuideline: ProfileIconImageGuideline.x48,
                emojiImageGuideline: EmojiIconImageGuideline.x48,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x48,
                staticImageGuideline: StaticImageGuideline.x24,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24,
                spaceImageGuideline: SpaceIconImageGuideline.x48
            )
        case let .mention(type):
            return mentionImageGuidelineSet(for: type)
        case .editorAccessorySearch:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: nil,
                profileImageGuideline: nil,
                emojiImageGuideline: EmojiIconImageGuideline.x52,
                todoImageGuideline: nil,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x52,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
        case .setRow:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        case .setCollection:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x16,
                profileImageGuideline: ProfileIconImageGuideline.x16,
                emojiImageGuideline: EmojiIconImageGuideline.x16,
                todoImageGuideline: TodoIconImageGuideline.x16,
                placeholderImageGuideline: nil,
                staticImageGuideline: nil,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x16,
                spaceImageGuideline: nil
            )
        case .featuredRelationsBlock:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x18,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        case .widgetTree:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x18,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        case .homeBottomPanel:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x24,
                profileImageGuideline: ProfileIconImageGuideline.x24,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x32,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24,
                spaceImageGuideline: SpaceIconImageGuideline.x24
            )
        case .inlineSetHeader:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x32,
                profileImageGuideline: ProfileIconImageGuideline.x32,
                emojiImageGuideline: EmojiIconImageGuideline.x32,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x32,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x28,
                spaceImageGuideline: nil
            )
        case .settingsHeader:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x96,
                profileImageGuideline: ProfileIconImageGuideline.x96,
                emojiImageGuideline: EmojiIconImageGuideline.x96,
                todoImageGuideline: nil,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x96,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: SpaceIconImageGuideline.x96
            )
        case .settingsSection:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x28,
                profileImageGuideline: ProfileIconImageGuideline.x28,
                emojiImageGuideline: EmojiIconImageGuideline.x28,
                todoImageGuideline: TodoIconImageGuideline.x28,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x28,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x28,
                spaceImageGuideline: nil
            )
        case .templatePreview:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x32,
                profileImageGuideline: ProfileIconImageGuideline.x32,
                emojiImageGuideline: EmojiIconImageGuideline.x32cornerRadius,
                todoImageGuideline: TodoIconImageGuideline.x14,
                placeholderImageGuideline: PlaceholderIconImageGuideline.x32,
                staticImageGuideline: nil,
                bookmarkImageGuideline: nil,
                spaceImageGuideline: nil
            )
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
                staticImageGuideline: StaticImageGuideline.x28,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x28,
                spaceImageGuideline: nil
            )
        case .heading:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x24,
                profileImageGuideline: ProfileIconImageGuideline.x24,
                emojiImageGuideline: EmojiIconImageGuideline.x24,
                todoImageGuideline: TodoIconImageGuideline.x24,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x24,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x24,
                spaceImageGuideline: nil
            )
        case .subheading, .body:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x20,
                profileImageGuideline: ProfileIconImageGuideline.x20,
                emojiImageGuideline: EmojiIconImageGuideline.x20,
                todoImageGuideline: TodoIconImageGuideline.x20,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x20,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x20,
                spaceImageGuideline: nil
            )
        case .callout:
            return ObjectIconImageGuidelineSet(
                basicImageGuideline: BasicIconImageGuideline.x18,
                profileImageGuideline: ProfileIconImageGuideline.x18,
                emojiImageGuideline: EmojiIconImageGuideline.x18,
                todoImageGuideline: TodoIconImageGuideline.x18,
                placeholderImageGuideline: nil,
                staticImageGuideline: StaticImageGuideline.x18,
                bookmarkImageGuideline: BookmarkIconImageGuideline.x18,
                spaceImageGuideline: nil
            )
        }
    }
}
