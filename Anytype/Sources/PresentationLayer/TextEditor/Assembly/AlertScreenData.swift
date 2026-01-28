struct ObjectInfo: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String
    
    var id: String { objectId + spaceId }
}

struct ChatCreateScreenData: Hashable, Identifiable {
    let spaceId: String
    let collectionId: String?
    let analyticsRoute: AnalyticsEventsRouteKind
    /// Document ID where to insert a link block after chat creation (for slash menu)
    let linkDocumentId: String?
    /// Target block ID after which to insert the link (for slash menu)
    let linkTargetBlockId: String?

    var id: Int { hashValue }

    init(
        spaceId: String,
        collectionId: String? = nil,
        analyticsRoute: AnalyticsEventsRouteKind,
        linkDocumentId: String? = nil,
        linkTargetBlockId: String? = nil
    ) {
        self.spaceId = spaceId
        self.collectionId = collectionId
        self.analyticsRoute = analyticsRoute
        self.linkDocumentId = linkDocumentId
        self.linkTargetBlockId = linkTargetBlockId
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
