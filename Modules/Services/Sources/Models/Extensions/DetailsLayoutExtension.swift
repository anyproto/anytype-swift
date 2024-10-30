import AnytypeCore

public extension DetailsLayout {
    
    static let editorLayouts: [DetailsLayout] = [ .note, .basic, .profile, .todo ]
    static let listLayouts: [DetailsLayout] = [ .collection, .set ]
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    static let fileAndMediaLayouts = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts
    
    static let visibleLayouts: [DetailsLayout] = listLayouts + editorLayouts + [.bookmark] + [.participant] + dateLayout + chatLayout
    static let visibleLayoutsWithFiles = visibleLayouts + fileAndMediaLayouts
    
    private static let supportedForCreationInSets: [DetailsLayout] = editorLayouts + [.bookmark]
    private static let layoutsWithIcon: [DetailsLayout] = listLayouts + fileAndMediaLayouts + [.basic, .profile]
    private static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    private static let dateLayout: [DetailsLayout] = FeatureFlags.dateAsAnObject ? [.date] : []
    private static let chatLayout: [DetailsLayout] = FeatureFlags.chats ? [.chat] : []
}

// MARK: - Computed properties

public extension DetailsLayout {
    var isVisible: Bool { DetailsLayout.visibleLayouts.contains(self) }
    var isVisibleOrFile: Bool { DetailsLayout.visibleLayoutsWithFiles.contains(self) }
    var isEditorLayout: Bool { DetailsLayout.editorLayouts.contains(self) }
    var isFileOrMedia: Bool { Self.fileAndMediaLayouts.contains(self) }
    var isSupportedForCreationInSets: Bool { Self.supportedForCreationInSets.contains(self) }
    var haveIcon: Bool { Self.layoutsWithIcon.contains(self) }
    var haveCover: Bool { Self.layoutsWithCover.contains(self) }
    
    var isNote: Bool { self == .note }
    var isImage: Bool { self == .image }
    
    var isSet: Bool { self == .set }
    var isCollection: Bool { self == .collection }
    var isList: Bool { Self.listLayouts.contains(self) }
}

public extension Optional where Wrapped == DetailsLayout {
    var isFileOrMedia: Bool {
        guard let self else { return false }
        return self.isFileOrMedia
    }
    
    var isEditorLayout: Bool {
        guard let self else { return false }
        return self.isEditorLayout
    }
    
    var isNote: Bool {
        guard let self else { return false }
        return self.isNote
    }
    
    var isImage: Bool {
        guard let self else { return false }
        return self.isImage
    }
    
    var isSet: Bool {
        guard let self else { return false }
        return self.isSet
    }
    var isCollection: Bool {
        guard let self else { return false }
        return self.isCollection
    }
    
    var isList: Bool {
        guard let self else { return false }
        return self.isList
    }
}
