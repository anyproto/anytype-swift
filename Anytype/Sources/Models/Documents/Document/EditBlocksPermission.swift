import Foundation

enum BlocksReadonlyReason {
    case locked
    case archived
    case spaceIsReadonly
    case restrictions
}

enum EditBlocksPermission {
    case edit
    case readonly(BlocksReadonlyReason)
}

extension EditBlocksPermission {
    var canEdit: Bool {
        switch self {
        case .edit:
            return true
        case .readonly:
            return false
        }
    }
}
