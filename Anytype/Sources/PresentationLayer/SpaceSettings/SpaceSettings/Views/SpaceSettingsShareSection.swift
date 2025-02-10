import Foundation

enum PrivateSpaceSettingsShareSection {
    case unshareable
    case shareable
    case reachedSharesLimit(limit: Int)
}

enum SpaceSettingsShareSection {
    case personal
    case `private`(state: PrivateSpaceSettingsShareSection)
    case owner(joiningCount: Int)
    case member
}

extension SpaceSettingsShareSection {
    var isSharingAvailable: Bool {
        
        switch self {
        case .personal, .private, .member:
            false
        case .owner:
            true
        }
    }
}
