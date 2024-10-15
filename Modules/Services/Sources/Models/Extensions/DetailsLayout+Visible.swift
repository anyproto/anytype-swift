import AnytypeCore

public extension DetailsLayout {
    // TODO: Rename
    static let visibleLayouts: [DetailsLayout] = pageLayouts + setLayouts
    static let visibleLayoutsWithFiles = visibleLayouts + fileAndMediaLayouts
    
    static let supportedForCreationInSets: [DetailsLayout] = pageLayouts - [.participant]

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
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    
    static let setLayouts: [DetailsLayout] = [ .collection, .set ]
    
    static let layoutsWithIcon: [DetailsLayout] = setLayouts + [.basic, .profile, .file, .image, .pdf, .audio, .video]
    static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
}

// MARK: - Templates
public extension DetailsLayout {
    var isTemplatesAvailable: Bool {
        DetailsLayout.layoutsWithTemplate.contains(self)
    }
    
    private static let layoutsWithTemplate: [DetailsLayout] = editorLayouts - [.participant]
}
