import Foundation
import Services

enum MessageLinkedObjectsLayout: Equatable, Hashable {
    case list([MessageAttachmentDetails])
    case grid([[MessageAttachmentDetails]])
    case bookmark(ObjectDetails)
}

extension MessageLinkedObjectsLayout {
    var isGrid: Bool {
        switch self {
        case .list, .bookmark:
            return false
        case .grid:
            return true
        }
    }
}
