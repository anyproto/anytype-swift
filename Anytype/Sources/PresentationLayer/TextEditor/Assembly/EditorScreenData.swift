import BlocksModels
import AnytypeCore

struct EditorScreenData: Hashable {
    let pageId: BlockId
    let type: EditorViewType
    let isOpenedForPreview: Bool

    init(pageId: BlockId, type: EditorViewType, isOpenedForPreview: Bool = false) {
        self.pageId = pageId
        self.type = type
        self.isOpenedForPreview = isOpenedForPreview
    }
}

enum EditorViewType: Hashable {
    case page
    case set(blockId: BlockId? = nil, targetObjectID: String? = nil)
    case favorites
    case recent
    case sets
    case collections
    case bin
    
    init?(rawValue: String, blockId: BlockId?, targetObjectID: String?) {
        switch rawValue {
        case "page":
            self = .page
        case "set":
            self = .set(blockId: blockId, targetObjectID: targetObjectID)
        case "favorites":
            self = .favorites
        case "recent":
            self = .recent
        case "sets":
            self = .sets
        case "collections":
            self = .collections
        case "bin":
            self = .bin
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .page: return "page"
        case .set: return "set"
        case .favorites: return "favorites"
        case .recent: return "recent"
        case .sets: return "sets"
        case .collections: return "collections"
        case .bin: return "bin"
        }
    }
}
