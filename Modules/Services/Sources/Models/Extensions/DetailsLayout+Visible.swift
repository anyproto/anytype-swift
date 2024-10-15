import AnytypeCore

public extension DetailsLayout {

    static let editorLayouts: [DetailsLayout] = [ .note, .basic, .profile, .todo ]
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    static let fileAndMediaLayouts = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts
    
    static let setLayouts: [DetailsLayout] = [ .collection, .set ] // TODO: Rename
    
    static let layoutsWithIcon: [DetailsLayout] = setLayouts + fileAndMediaLayouts + [.basic, .profile]
    static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    
    static let visibleLayouts: [DetailsLayout] = setLayouts + editorLayouts + [.bookmark] + [.participant] // TODO: Rename
    static let visibleLayoutsWithFiles = visibleLayouts + fileAndMediaLayouts
    
    static let supportedForCreationInSets: [DetailsLayout] = editorLayouts + [.bookmark]
    
    
    // MARK: - Templates
    var isTemplatesAvailable: Bool {
        DetailsLayout.editorLayouts.contains(self)
    }
    
}
