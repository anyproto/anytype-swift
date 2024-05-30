import Services
import AnytypeCore

enum BaseDocumentUpdate: Hashable {
    // From DocumentUpdate
    case general
    case syncStatus
    case block(blockId: String)
    case children
    case details(id: String)
    case unhandled(blockId: String)
    // Local State
}

extension DocumentUpdate {
    var toBaseDocumentUpdate: [BaseDocumentUpdate] {
        switch self {
        case .general:
            return [.general]
        case .syncStatus:
            return [.syncStatus]
        case .block(let blockId):
            return [.block(blockId: blockId)]
        case .children(let blockId):
            return [.block(blockId: blockId), .children]
        case .details(let id):
            return [.details(id: id)]
        case .unhandled(let blockId):
            return [.unhandled(blockId: blockId)]
        }
    }
}
