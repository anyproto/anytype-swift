struct ObjectInfo: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String

    var id: String { objectId + spaceId }
}

enum ChatCreateMode: Hashable {
    case create
    case edit(objectId: String, currentName: String, currentIcon: Icon)
}

struct ChatCreateScreenData: Hashable, Identifiable {
    let spaceId: String
    let mode: ChatCreateMode
    let collectionId: String?
    let analyticsRoute: AnalyticsEventsRouteKind
    /// Document ID where to insert a link block after chat creation (for slash menu)
    let linkDocumentId: String?
    /// Target block ID after which to insert the link (for slash menu)
    let linkTargetBlockId: String?

    var id: Int { hashValue }

    init(
        spaceId: String,
        mode: ChatCreateMode = .create,
        collectionId: String? = nil,
        analyticsRoute: AnalyticsEventsRouteKind,
        linkDocumentId: String? = nil,
        linkTargetBlockId: String? = nil
    ) {
        self.spaceId = spaceId
        self.mode = mode
        self.collectionId = collectionId
        self.analyticsRoute = analyticsRoute
        self.linkDocumentId = linkDocumentId
        self.linkTargetBlockId = linkTargetBlockId
    }
}

extension ChatCreateScreenData {
    var screenTitle: String {
        switch mode {
        case .create:
            return Loc.createChat
        case .edit:
            return Loc.editInfo
        }
    }

    var buttonTitle: String {
        switch mode {
        case .create:
            return Loc.create
        case .edit:
            return Loc.save
        }
    }
}

struct BookmarkCreateScreenData: Hashable, Identifiable {
    let spaceId: String
    let collectionId: String?
    let analyticsRoute: AnalyticsEventsRouteKind

    var id: Int { hashValue }

    init(spaceId: String, collectionId: String? = nil, analyticsRoute: AnalyticsEventsRouteKind) {
        self.spaceId = spaceId
        self.collectionId = collectionId
        self.analyticsRoute = analyticsRoute
    }
}

enum AlertScreenData: Hashable {
    case spaceMember(ObjectInfo)
    case chatCreate(ChatCreateScreenData)
    case bookmarkCreate(BookmarkCreateScreenData)
    case widgets(HomeWidgetData)

    var objectId: String? {
        switch self {
        case .spaceMember(let info):
            info.objectId
        case .chatCreate, .bookmarkCreate, .widgets:
            nil
        }
    }

    var spaceId: String {
        switch self {
        case .spaceMember(let info):
            info.spaceId
        case .chatCreate(let data):
            data.spaceId
        case .bookmarkCreate(let data):
            data.spaceId
        case .widgets(let data):
            data.spaceId
        }
    }
}
