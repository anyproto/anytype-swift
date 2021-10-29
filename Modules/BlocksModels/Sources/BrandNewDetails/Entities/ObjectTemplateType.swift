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
            self = .known(knownType)
        } else {
            self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .known(let knownType):
            return knownType.rawValue
        case .unknown(let string):
            return string
        }
    }

    case known(KnownType)
    case unknown(String)
}
