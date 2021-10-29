import Foundation

public enum ObjectTemplateType: RawRepresentable {
    public enum KnownType: String {
        case page = "_otpage"
        case profile = "_otprofile"
        case note = "_otnote"
        case set = "_otset"
    }

    public init?(rawValue: String) {
        if let knownType = KnownType(rawValue: rawValue) {
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

    case bundled(KnownType)
    case dynamic(String)
}
