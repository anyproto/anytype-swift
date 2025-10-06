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
    case editor
    case viewer
}

extension SpaceSettingsShareSection {
    var isSharingAvailable: Bool {
        switch self {
        case .personal, .private, .viewer:
            false
        case .editor, .owner:
            true
        }
    }
}


