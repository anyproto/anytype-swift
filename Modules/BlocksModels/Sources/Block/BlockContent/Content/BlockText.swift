public struct BlockText: Hashable {
    private static var defaultChecked = false
    public var attributedText: NSAttributedString

    /// Block color
    public var color: MiddlewareColor?
    public var contentType: ContentType
    public var checked: Bool
    public var number: Int
    
    // MARK: - Memberwise initializer
    public init(attributedText: NSAttributedString, color: MiddlewareColor?, contentType: ContentType, checked: Bool, number: Int = 1) {
        self.attributedText = attributedText
        self.color = color
        self.contentType = contentType
        self.checked = checked
        self.number = number
    }
}

// MARK: ContentType / Text / Supplements
public extension BlockText {
    init(contentType: ContentType) {
        self.init(attributedText: .init(), color: nil, contentType: contentType, checked: Self.defaultChecked)
    }
            
    // MARK: - Create

    static func empty() -> Self {
        self.createDefault(text: "")
    }

    static func createDefault(text: String) -> Self {
        .init(attributedText: .init(string: text), color: nil, contentType: .text, checked: Self.defaultChecked)
    }
}

// MARK: ContentType / Text / ContentType
public extension BlockText {
    enum ContentType {
        case title
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
        
        /// Returns true in case of content type is list, otherwise returns false
        public var isList: Bool {
            switch self {
            case .checkbox, .bulleted, .numbered, .toggle:
                return true
            default:
                return false
            }
        }
        
        /// Returns true in case of .checkbox, .bulleted, .numbered, otherwise returns false
        public var isListAndNotToggle: Bool {
            switch self {
            case .checkbox , .bulleted, .numbered:
                return true
            default:
                return false
            }
        }
    }
}
