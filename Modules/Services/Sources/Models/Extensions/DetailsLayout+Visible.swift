
public extension DetailsLayout {
    
    static var visibleLayouts: [DetailsLayout] = DetailsLayout.supportedForUserCreateLayouts + DetailsLayout.fileLayouts
    static var supportedForEditLayouts: [DetailsLayout] = DetailsLayout.supportedForUserCreateLayouts + DetailsLayout.fileLayouts
    
    static var supportedForUserCreateLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .note, .profile, .set, .todo]
}


// For editor
public extension DetailsLayout {
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
    
    static var fileLayouts: [DetailsLayout] = [
        .file,
        .image,
        .audio,
        .video
    ]
    
    static var systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionList,
        .dashboard,
        .database
    ]
    
    static var pageLayouts: [DetailsLayout] = [
        .basic,
        .profile,
        .todo,
        .note,
        .bookmark
    ]
    
    static var fileAndSystemLayouts: [DetailsLayout] = fileLayouts + systemLayouts
    static var layoutsWithoutTemplate: [DetailsLayout] = [
        .note,
        .set,
        .collection,
        .bookmark
    ] + fileAndSystemLayouts
    
    
    var isTemplatesAvailable: Bool {
        !DetailsLayout.layoutsWithoutTemplate.contains(self) &&
        DetailsLayout.pageLayouts.contains(self)
    }
}
