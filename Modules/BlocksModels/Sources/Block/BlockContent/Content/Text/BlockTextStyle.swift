import ProtobufMessages

public extension BlockText {
    enum Style {
        case title
        case description
        case text
        case header
        case header2
        case header3
        case header4
        case quote
        case checkbox
        case bulleted
        case numbered
        case toggle
        case code
        case callout
        
        public init?(_ model: Anytype_Model_Block.Content.Text.Style) {
            switch model {
            case .title: self = .title
            case .paragraph: self = .text
            case .header1: self = .header
            case .header2: self = .header2
            case .header3: self = .header3
            case .header4: self = .header4
            case .quote: self = .quote
            case .code: self = .code
            case .checkbox: self = .checkbox
            case .marked: self = .bulleted
            case .numbered: self = .numbered
            case .toggle: self = .toggle
            case .description_: self = .description
            case .callout: self = .callout
            case .UNRECOGNIZED: return nil
            }
        }
        
        /// Returns true in case of content type is list, otherwise returns false
        public var isList: Bool {
            switch self {
            case .checkbox, .bulleted, .numbered, .toggle:
                return true
            default:
                return false
            }
        }
        
        public var asMiddleware: Anytype_Model_Block.Content.Text.Style {
            switch self {
            case .title: return .title
            case .description: return .description_
            case .text: return .paragraph
            case .header: return .header1
            case .header2: return .header2
            case .header3: return .header3
            case .header4: return .header4
            case .quote: return .quote
            case .checkbox: return .checkbox
            case .bulleted: return .marked
            case .numbered: return .numbered
            case .toggle: return .toggle
            case .code: return .code
            case .callout: return .callout
            }
        }
    }
}
