import Foundation
import Services

extension SpaceAccessType {
    var canBeShared: Bool {
        switch self {
        case .personal, .UNRECOGNIZED:
            return false
        case .private, .shared:
            return true
        }
    }
}
