import ProtobufMessages

public extension DetailsLayout {
    
    static let editorLayouts: [DetailsLayout] = [ .note, .basic, .profile, .todo ]
    static let listLayouts: [DetailsLayout] = [ .collection, .set ]
    
    static let fileLayouts: [DetailsLayout] = [ .file, .pdf ]
    static let mediaLayouts: [DetailsLayout] = [ .image, .audio, .video ]
    static let fileAndMediaLayouts = DetailsLayout.fileLayouts + DetailsLayout.mediaLayouts

    fileprivate static let visibleLayoutsBase: [DetailsLayout] = listLayouts + editorLayouts + [.bookmark, .date, .objectType]
    fileprivate static let visibleLayoutsWithFilesBase = visibleLayoutsBase + fileAndMediaLayouts

    fileprivate static let supportedForCreationBase: [DetailsLayout] = supportedForCreationInSetsBase + listLayouts
    fileprivate static let supportedForSharingExtensionBase: [DetailsLayout] = [.collection] + editorLayouts

    fileprivate static let widgetTypeLayoutsBase = listLayouts + editorLayouts + [.bookmark] + fileAndMediaLayouts

    private static let supportedForOpening: [DetailsLayout] = visibleLayoutsWithFilesBase + [.objectType, .participant] + chatLayouts

    private static let supportedForCreationInSetsBase: [DetailsLayout] = editorLayouts + [.bookmark] + listLayouts
    private static let layoutsWithIcon: [DetailsLayout] = listLayouts + fileAndMediaLayouts + [.basic, .profile, .objectType]
    private static let layoutsWithCover: [DetailsLayout] = layoutsWithIcon + [.bookmark, .todo]
    private static let chatLayouts: [DetailsLayout] = [.chatDerived]
}

// MARK: - Space-aware filtering (SpaceUxType) — deprecated

public extension DetailsLayout {
    @available(*, deprecated, message: "Use spaceType overload instead")
    static func visibleLayouts(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return visibleLayoutsBase }
        return visibleLayoutsBase + chatLayouts
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    static func visibleLayoutsWithFiles(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return visibleLayoutsWithFilesBase }
        return visibleLayoutsWithFilesBase + chatLayouts
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    static func supportedForCreation(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return supportedForCreationBase }
        return supportedForCreationBase + chatLayouts
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    static func supportedForCreationInSets(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return supportedForCreationInSetsBase }
        return supportedForCreationInSetsBase + chatLayouts
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    static func widgetTypeLayouts(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return widgetTypeLayoutsBase }
        return widgetTypeLayoutsBase + chatLayouts
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    static func supportedForSharingExtension(spaceUxType: SpaceUxType?) -> [DetailsLayout] {
        guard spaceUxType.supportsMultiChats else { return supportedForSharingExtensionBase }
        return supportedForSharingExtensionBase + chatLayouts
    }
}

// MARK: - Space-aware filtering (SpaceType)

public extension DetailsLayout {
    static func visibleLayouts(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return visibleLayoutsBase }
        return visibleLayoutsBase + chatLayouts
    }

    static func visibleLayoutsWithFiles(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return visibleLayoutsWithFilesBase }
        return visibleLayoutsWithFilesBase + chatLayouts
    }

    static func supportedForCreation(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return supportedForCreationBase }
        return supportedForCreationBase + chatLayouts
    }

    static func supportedForCreationInSets(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return supportedForCreationInSetsBase }
        return supportedForCreationInSetsBase + chatLayouts
    }

    static func widgetTypeLayouts(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return widgetTypeLayoutsBase }
        return widgetTypeLayoutsBase + chatLayouts
    }

    static func supportedForSharingExtension(spaceType: SpaceType?) -> [DetailsLayout] {
        guard spaceType != .oneToOne else { return supportedForSharingExtensionBase }
        return supportedForSharingExtensionBase + chatLayouts
    }
}

// MARK: - Computed properties

public extension DetailsLayout {
    var isEditorLayout: Bool { DetailsLayout.editorLayouts.contains(self) }
    var isFile: Bool { Self.fileLayouts.contains(self) }
    var isFileOrMedia: Bool { Self.fileAndMediaLayouts.contains(self) }
    var isSupportedForOpening: Bool { Self.supportedForOpening.contains(self) }
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
    var isChat: Bool { Self.chatLayouts.contains(self) }

    var blockLinkType: Anytype_Model_ChatMessage.MessageBlockLink.LinkType {
        switch self {
        case .image: return .image
        case .file, .pdf, .audio, .video: return .file
        case .bookmark: return .bookmark
        default: return .object
        }
    }
}

// MARK: - Instance functions

public extension DetailsLayout {
    @available(*, deprecated, message: "Use spaceType overload instead")
    func isSupportedForCreation(spaceUxType: SpaceUxType?) -> Bool {
        Self.supportedForCreation(spaceUxType: spaceUxType).contains(self)
    }

    @available(*, deprecated, message: "Use spaceType overload instead")
    func isSupportedForCreationInSets(spaceUxType: SpaceUxType?) -> Bool {
        Self.supportedForCreationInSets(spaceUxType: spaceUxType).contains(self)
    }

    func isSupportedForCreation(spaceType: SpaceType?) -> Bool {
        Self.supportedForCreation(spaceType: spaceType).contains(self)
    }

    func isSupportedForCreationInSets(spaceType: SpaceType?) -> Bool {
        Self.supportedForCreationInSets(spaceType: spaceType).contains(self)
    }
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
