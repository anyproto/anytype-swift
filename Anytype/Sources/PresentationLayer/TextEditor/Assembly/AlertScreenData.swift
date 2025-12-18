struct ObjectInfo: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String
    
    var id: String { objectId + spaceId }
}

struct ChatCreateScreenData: Hashable, Identifiable {
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

    var objectId: String? {
        switch self {
        case .spaceMember(let info):
            info.objectId
        case .chatCreate, .bookmarkCreate:
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
        }
    }
}
