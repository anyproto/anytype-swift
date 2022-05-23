import Foundation

public enum ObjectTemplateType: RawRepresentable {
    public enum BundledType: String {
        case page = "_otpage"
        case profile = "_otprofile"
        case note = "_otnote"
        case set = "_otset"
        case task = "_ottask"
        case template = "_ottemplate"
    }

    public init?(rawValue: String) {
        if let knownType = BundledType(rawValue: rawValue) {
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

    case bundled(BundledType)
    case dynamic(String)
}
