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
    
    init?(rawValue: String, blockId: BlockId?, targetObjectID: String?) {
        switch rawValue {
        case "page":
            self = .page
        case "set":
            self = .set(blockId: blockId, targetObjectID: targetObjectID)
        default:
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .page: return "page"
        case .set: return "set"
        }
    }
}
