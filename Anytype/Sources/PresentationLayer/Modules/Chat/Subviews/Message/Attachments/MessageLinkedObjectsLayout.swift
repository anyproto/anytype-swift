import Foundation

enum MessageLinkedObjectsLayout: Equatable, Hashable {
    case list([MessageAttachmentDetails])
    case grid([[MessageAttachmentDetails]])
}

extension MessageLinkedObjectsLayout {
    var isGrid: Bool {
        switch self {
        case .list:
            return false
        case .grid:
            return true
        }
    }
}
