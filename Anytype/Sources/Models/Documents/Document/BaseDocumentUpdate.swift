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
    case relations
    case permissions
}
