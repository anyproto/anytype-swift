import Foundation

public enum PlaceholderType: Sendable {
    case value
    case today
    case currentUser
    case unrecognized(Int)

    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .value
        case 1: self = .today
        case 2: self = .currentUser
        default: self = .unrecognized(rawValue)
        }
    }
}
