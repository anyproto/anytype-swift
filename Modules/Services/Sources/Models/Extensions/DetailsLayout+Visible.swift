import AnytypeCore

public extension DetailsLayout {
    static let visibleLayouts: [DetailsLayout] = pageLayouts + setLayouts
    static let supportedForEditLayouts: [DetailsLayout] =  pageLayouts + fileLayouts + setLayouts
    static let supportedForCreationInSets: [DetailsLayout] = pageLayouts - [.participant]
    static let visibleLayoutsWithFiles = visibleLayouts + fileLayouts
}


// For editor
public extension DetailsLayout {
    static let editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo,
        .participant
    ]
    
    static let pageLayouts: [DetailsLayout] = editorLayouts + [.bookmark]
    
    static let fileLayouts: [DetailsLayout] = [
        .file,
        .image,
        .audio,
        .video,
        .pdf
    ]
    
    static let setLayouts: [DetailsLayout] = [
        .collection,
        .set
    ]
    
    static let systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionsList,
        .dashboard,
        .space
    ]
    
    static let fileAndSystemLayouts: [DetailsLayout] = fileLayouts + systemLayouts
    static let layoutsWithoutTemplate: [DetailsLayout] = [
        .set,
        .collection,
        .bookmark,
        .participant
    ] + fileAndSystemLayouts
    
    
    var isTemplatesAvailable: Bool {
        !DetailsLayout.layoutsWithoutTemplate.contains(self) &&
        DetailsLayout.pageLayouts.contains(self)
    }
    
    static let layoutsWithIcon: [DetailsLayout] = [.basic, .profile, .set, .collection, .file, .image]
    static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    static let layoutsWithChangeLayout: [DetailsLayout] = [.basic, .profile, .file, .image, .bookmark, .todo, .note]
}
