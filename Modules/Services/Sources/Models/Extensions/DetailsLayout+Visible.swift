import AnytypeCore

public extension DetailsLayout {
    static var visibleLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .note, .set, .todo, .participant]
    static var supportedForEditLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .file, .image, .note, .profile, .participant, .set, .todo]
    static var supportedForCreationInSets: [DetailsLayout] = pageLayouts
}


// For editor
public extension DetailsLayout {
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo,
        .participant
    ]
    
    static var pageLayouts: [DetailsLayout] = editorLayouts + [.bookmark]
    
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
        .database,
        .space
    ]
    
    static var fileAndSystemLayouts: [DetailsLayout] = fileLayouts + systemLayouts
    static var layoutsWithoutTemplate: [DetailsLayout] = [
        .set,
        .collection,
        .bookmark
    ] + fileAndSystemLayouts
    
    
    var isTemplatesAvailable: Bool {
        !DetailsLayout.layoutsWithoutTemplate.contains(self) &&
        DetailsLayout.pageLayouts.contains(self)
    }
}
