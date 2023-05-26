import Services

extension DetailsLayout {
    static var visibleLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .note, .profile, .set, .todo]
    static var supportedForEditLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .file, .image, .note, .profile, .set, .todo]
}


// For editor

extension DetailsLayout {
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
}
