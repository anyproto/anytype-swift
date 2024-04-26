import Foundation

enum SpaceSettingsShareSection {
    case personal
    case `private`(active: Bool)
    case owner(joiningCount: Int)
    case member
}
