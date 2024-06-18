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
