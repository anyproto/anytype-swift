import Foundation

public enum ObjectTypeId: RawRepresentable {
    public init?(rawValue: String) {
        self = .dynamic(rawValue)
    }

    public var rawValue: String {
        switch self {
        case .dynamic(let string):
            return string
        }
    }

    case dynamic(String)
}
