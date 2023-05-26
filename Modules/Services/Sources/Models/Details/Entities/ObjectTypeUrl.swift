import Foundation

public enum ObjectTypeId: RawRepresentable {
    public init?(rawValue: String) {
        if let knownType = BundledTypeId(rawValue: rawValue) {
            self = .bundled(knownType)
        } else {
            self = .dynamic(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .bundled(let knownType):
            return knownType.rawValue
        case .dynamic(let string):
            return string
        }
    }

    case bundled(BundledTypeId)
    case dynamic(String)
}
