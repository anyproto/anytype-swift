public extension DetailsLayout {
    
    static let editorLayouts: [DetailsLayout] = [ .note, .basic, .profile, .todo ]
    static let listLayouts: [DetailsLayout] = [ .collection, .set ]
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    static let fileAndMediaLayouts = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts

    fileprivate static let visibleLayoutsBase: [DetailsLayout] = listLayouts + editorLayouts + [.bookmark, .participant, .date, .objectType] + chatLayouts
    fileprivate static let visibleLayoutsWithFilesBase = visibleLayoutsBase + fileAndMediaLayouts

    fileprivate static let supportedForCreationBase: [DetailsLayout] = supportedForCreationInSets + listLayouts + chatLayouts
    static let supportedForSharingExtension: [DetailsLayout] = [.collection] + editorLayouts

    fileprivate static let widgetTypeLayoutsBase = listLayouts + editorLayouts + [.bookmark] + fileAndMediaLayouts + chatLayouts

    private static let supportedForOpening: [DetailsLayout] = visibleLayoutsWithFilesBase + [.objectType]

    private static let supportedForCreationInSets: [DetailsLayout] = editorLayouts + [.bookmark] + listLayouts
    private static let layoutsWithIcon: [DetailsLayout] = listLayouts + fileAndMediaLayouts + [.basic, .profile, .objectType]
    private static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    private static let chatLayouts: [DetailsLayout] = [.chatDerived]
}

// MARK: - Space-aware filtering

public extension DetailsLayout {
    static func visibleLayouts(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard !(spaceUxType?.showsChatLayouts ?? true) else { return visibleLayoutsBase }
        return visibleLayoutsBase.filter { $0 != .chatDerived }
    }

    static func visibleLayoutsWithFiles(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard !(spaceUxType?.showsChatLayouts ?? true) else { return visibleLayoutsWithFilesBase }
        return visibleLayoutsWithFilesBase.filter { $0 != .chatDerived }
    }

    static func supportedForCreation(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard !(spaceUxType?.showsChatLayouts ?? true) else { return supportedForCreationBase }
        return supportedForCreationBase.filter { $0 != .chatDerived }
    }

    static func widgetTypeLayouts(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard !(spaceUxType?.showsChatLayouts ?? true) else { return widgetTypeLayoutsBase }
        return widgetTypeLayoutsBase.filter { $0 != .chatDerived }
    }
}

// MARK: - Computed properties

public extension DetailsLayout {
    var isVisible: Bool { DetailsLayout.visibleLayoutsBase.contains(self) }
    var isVisibleOrFile: Bool { DetailsLayout.visibleLayoutsWithFilesBase.contains(self) }
    var isEditorLayout: Bool { DetailsLayout.editorLayouts.contains(self) }
    var isFile: Bool { Self.fileLayouts.contains(self) }
    var isFileOrMedia: Bool { Self.fileAndMediaLayouts.contains(self) }
    var isSupportedForCreationInSets: Bool { Self.supportedForCreationInSets.contains(self) }
    var isSupportedForOpening: Bool { Self.supportedForOpening.contains(self) }
    var isSupportedForCreation: Bool { Self.supportedForCreationBase.contains(self) }
    var haveIcon: Bool { Self.layoutsWithIcon.contains(self) }
    var haveCover: Bool { Self.layoutsWithCover.contains(self) }
    
    var isNote: Bool { self == .note }
    var isImage: Bool { self == .image }
    var isParticipant: Bool { self == .participant }
    var isDate: Bool { self == .date }
    var isBookmark: Bool { self == .bookmark }
    
    var isSet: Bool { self == .set }
    var isCollection: Bool { self == .collection }
    var isList: Bool { Self.listLayouts.contains(self) }
    
    var isObjectType: Bool { self == .objectType }
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
