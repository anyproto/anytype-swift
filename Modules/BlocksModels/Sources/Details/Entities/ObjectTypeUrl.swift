import Foundation

public enum ObjectTypeId: RawRepresentable {
    public enum BundledTypeId: String {
        case page = "ot-page"
        case profile = "ot-profile"
        case note = "ot-note"
        case set = "ot-set"
        case task = "ot-task"
        case template = "ot-template"
        case bookmark = "ot-bookmark"
        case objectType = "ot-objectType"
        case relation = "ot-relation"
        case relationOption = "ot-relationOption"
        case systemObjectType = "_otobjectType"
        case systemBookmark = "_otbookmark"
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
