import Foundation

public enum BlockContent {
    case smartblock(Smartblock)
    case text(Text)
    case file(File)
    case divider(Divider)
    case bookmark(Bookmark)
    case link(Link)
    case layout(Layout)
    
    public var type: BlockContentType {
        switch self {
        case let .smartblock(smartblock):
            return .smartblock(smartblock.style)
        case let .text(text):
            return .text(text.contentType)
        case let .file(file):
            return  .file(file.contentType)
        case let .divider(divider):
            return .divider(divider.style)
        case let .bookmark(bookmark):
            return .bookmark(bookmark.type)
        case let .link(link):
            return .link(link.style)
        case let .layout(layout):
            return .layout(layout.style)
        }
    }
}

/// ContentType / Cases
public extension BlockContent {
    var kind: Kind { .init(attribute: self, strategy: .topLevel) }
    var deepKind: Kind { .init(attribute: self, strategy: .levelOne) }
}

public extension BlockContent {
    struct KindComparator: Equatable {
        fileprivate enum Strategy {
            case topLevel
            case levelOne
            func same(_ lhs: Element, _ rhs: Element) -> Bool {
                switch self {
                case .topLevel:
                    switch (lhs, rhs) {
                    case (.text, .text): return true
                    case (.smartblock, .smartblock): return true
                    case (.file, .file): return true
                    case (.divider, .divider): return true
                    case (.bookmark, .bookmark): return true
                    case (.link, .link): return true
                    default: return false
                    }
                case .levelOne:
                    guard Strategy.topLevel.same(lhs, rhs) else {
                        return false
                    }
                    switch (lhs, rhs) {
                    case let (.text(left), .text(right)): return left.contentType == right.contentType
                    case let (.divider(left), .divider(right)): return left.style == right.style
                    default: return true
                    }
                }
            }
        }
        
        typealias Element = BlockContent
        
        var attribute: Element
        fileprivate var strategy: Strategy = .topLevel
        
        func sameKind(_ value: Element) -> Bool {
            self.same(self.attribute, value)
        }
        func sameKind(_ value: Kind) -> Bool {
            self.same(self.attribute, value.attribute)
        }
        func same(_ lhs: Element, _ rhs: Element) -> Bool {
            self.strategy.same(lhs, rhs)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.sameKind(rhs)
        }
    }
    
    typealias Kind = KindComparator
}

// MARK: ContentType / Text
public extension BlockContent {
    struct Text {
        private static var defaultChecked = false
        private static var defaultColor = ""
        public var attributedText: NSAttributedString

        /// Block color
        public var color: String
        public var contentType: ContentType
        public var checked: Bool
        public var number: Int
        
        // MARK: - Memberwise initializer
        public init(attributedText: NSAttributedString, color: String, contentType: ContentType, checked: Bool, number: Int = 1) {
            self.attributedText = attributedText
            self.color = color
            self.contentType = contentType
            self.checked = checked
            self.number = number
        }
    }
}

// MARK: ContentType / Text / Supplements
public extension BlockContent.Text {
    init(contentType: ContentType) {
        self.init(attributedText: .init(), color: Self.defaultColor, contentType: contentType, checked: Self.defaultChecked)
    }
            
    // MARK: - Create

    static func empty() -> Self {
        self.createDefault(text: "")
    }

    static func createDefault(text: String) -> Self {
        .init(attributedText: .init(string: text), color: Self.defaultColor, contentType: .text, checked: Self.defaultChecked)
    }
}

// MARK: ContentType / Text / ContentType
public extension BlockContent.Text {
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

// MARK: ContentType / Smartblock
public extension BlockContent {
    struct Smartblock {
        public var style: Style = .page
        
        // MARK: - Memberwise initializer
        public init(style: BlockContent.Smartblock.Style = .page) {
            self.style = style
        }
    }
}

// MARK: ContentType / Smartblock / Style
public extension BlockContent.Smartblock {
    enum Style {
        case page
        case home
        case profilePage
        case archive
        case breadcrumbs
    }
}

// MARK: ContentType / File
public extension BlockContent {
    struct File {
        public var metadata: Metadata

        /// Our entries
        public var contentType: ContentType
        public var state: State

        // MARK: - Designed initializer
        public init(contentType: ContentType) {
            self.init(metadata: .empty(), contentType: contentType, state: .empty)
        }
        
        // MARK: - Memberwise initializer
        public init(metadata: Metadata, contentType: ContentType, state: State) {
            self.metadata = metadata
            self.contentType = contentType
            self.state = state
        }
    }
}

// MARK: ContentType / File / Metadata
public extension BlockContent.File {
    struct Metadata {
        public var name: String
        public var size: Int64
        public var hash: String
        public var mime: String
        public var addedAt: Int64
        
        public static func empty() -> Self {
            .init(name: "", size: 0, hash: "", mime: "", addedAt: 0)
        }
        
        // MARK: - Memberwise initializer
        public init(name: String, size: Int64, hash: String, mime: String, addedAt: Int64) {
            self.name = name
            self.size = size
            self.hash = hash
            self.mime = mime
            self.addedAt = addedAt
        }
    }
}

// MARK: ContentType / File / ContentType
public extension BlockContent.File {
    enum ContentType {
        case none
        case file
        case image
        case video
    }
}

// MARK: ContentType / File / State
public extension BlockContent.File {
    enum State {
        /// There is no file and preview, it's an empty block, that waits files.
        case empty
        /// There is still no file/preview, but file already uploading
        case uploading
        /// File exists, uploading is done
        case done
        /// Error while uploading
        case error
    }
}

// MARK: ContentType / Divider
public extension BlockContent {
    // TODO: Add style to Div.
    struct Divider {
        public var style: Style
        // MARK: - Memberwise initializer
        public init(style: Style) {
            self.style = style
        }
    }
}

// MARK: ContentType / Divider / Style
public extension BlockContent.Divider {
    enum Style {
        case line // Line separator style
        case dots // Dots separator style
    }
}

// MARK: ContentType / Bookmark
public extension BlockContent {
    // Bookmark has something, maybe add it later.
    struct Bookmark {
        public var url: String
        public var title: String
        public var theDescription: String
        public var imageHash: String
        public var faviconHash: String
        public var type: TypeEnum

        // MARK: - Empty
        public static func empty() -> Self {
            .init(url: "", title: "", theDescription: "", imageHash: "", faviconHash: "", type: .unknown)
        }
        
        // MARK: - Memberwise initializer
        public init(url: String, title: String, theDescription: String, imageHash: String, faviconHash: String, type: TypeEnum) {
            self.url = url
            self.title = title
            self.theDescription = theDescription
            self.imageHash = imageHash
            self.faviconHash = faviconHash
            self.type = type
        }
    }
}

// MARK: ContentType / Bookmark / TypeEnum
public extension BlockContent.Bookmark {
    enum TypeEnum {
        case unknown
        case page
        case image
        case text
    }
}

// MARK: ContentType / Link
public extension BlockContent {
    struct Link {
        public var targetBlockID: String
        public var style: Style
        public var fields: [String: AnyHashable]
        
        // MARK: Designed initializer
        public init(style: Style) {
            self.init(targetBlockID: "", style: style, fields: [:])
        }
        
        // MARK: - Memberwise initializer
        public init(targetBlockID: String, style: Style, fields: [String : AnyHashable]) {
            self.targetBlockID = targetBlockID
            self.style = style
            self.fields = fields
        }
    }
}

// MARK: ContentType / Link / Style
public extension BlockContent.Link {
    enum Style {
        case page
        case dataview
        case archive
    }
}

// MARK: ContentType / Layout
public extension BlockContent {
    struct Layout {
        public var style: Style
        // MARK: - Memberwise initializer
        public init(style: Style) {
            self.style = style
        }
    }
}

// MARK: ContentType / Layout / Style
public extension BlockContent.Layout {
    enum Style {
        case row
        case column
        case div
        case header
    }
}

// MARK: - ContentType / Hashable
extension BlockContent: Hashable {}
extension BlockContent.Smartblock: Hashable {}
extension BlockContent.Text: Hashable {}
extension BlockContent.File: Hashable {}
extension BlockContent.File.Metadata: Hashable {}
extension BlockContent.Divider: Hashable {}
extension BlockContent.Bookmark: Hashable {}
extension BlockContent.Link: Hashable {}
extension BlockContent.Layout: Hashable {}
