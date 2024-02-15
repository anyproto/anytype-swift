import AnytypeCore

public extension DetailsLayout {
    static var visibleLayouts: [DetailsLayout] = pageLayouts + setLayouts - systemLayouts
    static var supportedForEditLayouts: [DetailsLayout] =  pageLayouts + fileLayouts + setLayouts
    static var supportedForCreationInSets: [DetailsLayout] = pageLayouts - [.participant]
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
        .video,
        .pdf
    ]
    
    static var setLayouts: [DetailsLayout] = [
        .collection,
        .set
    ]
    
    static var systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionsList,
        .dashboard,
        .space,
        .profile
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
