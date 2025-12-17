struct ObjectInfo: Hashable, Codable, Identifiable {
    let objectId: String
    let spaceId: String
    
    var id: String { objectId + spaceId }
}

struct ChatCreateScreenData: Hashable, Identifiable {
    let spaceId: String
    let collectionId: String?

    var id: Int { hashValue }

    init(spaceId: String, collectionId: String? = nil) {
        self.spaceId = spaceId
        self.collectionId = collectionId
    }
}

enum AlertScreenData: Hashable {
    case spaceMember(ObjectInfo)
    case chatCreate(ChatCreateScreenData)
    case widget(HomeWidgetData)

    var objectId: String? {
        switch self {
        case .spaceMember(let info):
            info.objectId
        case .widget:
            nil
        case .chatCreate:
            nil
        }
    }

    var spaceId: String {
        switch self {
        case .spaceMember(let info):
            info.spaceId
        case .chatCreate(let data):
            data.spaceId
        case .widget(let info):
            info.spaceId
        }
    }
}
