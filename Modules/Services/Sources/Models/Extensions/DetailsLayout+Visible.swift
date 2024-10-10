import AnytypeCore

public extension DetailsLayout {
    static let visibleLayouts: [DetailsLayout] = pageLayouts + setLayouts + chatLayouts
    static let supportedForEditLayouts: [DetailsLayout] =  pageLayouts + fileAndMediaLayouts + setLayouts
    static let supportedForCreationInSets: [DetailsLayout] = pageLayouts - [.participant]
    static let visibleLayoutsWithFiles = visibleLayouts + fileAndMediaLayouts
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
    
    static let editorChangeLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
    
    static let pageLayouts: [DetailsLayout] = editorLayouts + [.bookmark]
    
    static let fileAndMediaLayouts: [DetailsLayout] = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts
    
    static let fileLayouts: [DetailsLayout] = [
        .file,
        .pdf
    ]
    
    static let mediaLayouts: [DetailsLayout] = [
        .image,
        .audio,
        .video,
    ]
    
    static let setLayouts: [DetailsLayout] = [
        .collection,
        .set
    ]
    
    static let chatLayouts: [DetailsLayout] = FeatureFlags.discussions ? [.chat] : []
    
    static let systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionsList,
        .dashboard,
        .space
    ]
    
    static let fileMediaSystemLayouts: [DetailsLayout] = fileAndMediaLayouts + systemLayouts
    static let layoutsWithoutTemplate: [DetailsLayout] = [
        .set,
        .collection,
        .bookmark,
        .participant
    ] + fileMediaSystemLayouts
    
    
    var isTemplatesAvailable: Bool {
        !DetailsLayout.layoutsWithoutTemplate.contains(self) &&
        DetailsLayout.pageLayouts.contains(self)
    }
    
    static let layoutsWithIcon: [DetailsLayout] = [.basic, .profile, .set, .collection, .file, .image]
    static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    static let layoutsWithChangeLayout: [DetailsLayout] = [.basic, .profile, .file, .image, .bookmark, .todo, .note]
}
