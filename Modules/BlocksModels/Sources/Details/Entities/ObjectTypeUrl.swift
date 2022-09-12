import Foundation

public enum ObjectTypeId: RawRepresentable {
    public enum BundledTypeId: String {
        case page = "_otpage"
        case profile = "_otprofile"
        case note = "_otnote"
        case set = "_otset"
        case task = "_ottask"
        case template = "_ottemplate"
        case bookmark = "_otbookmark"
        case objectType = "_otobjectType"
        case relation = "_otrelation"
        case relationOption = "_otrelationOption"
    }

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
