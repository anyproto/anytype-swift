import Foundation

public enum BlockContent {
    case smartblock(Smartblock)
    case text(BlockText)
    case file(File)
    case divider(Divider)
    case bookmark(Bookmark)
    case link(BlockLink)
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
extension BlockContent.File: Hashable {}
extension BlockContent.File.Metadata: Hashable {}
extension BlockContent.Divider: Hashable {}
extension BlockContent.Bookmark: Hashable {}
extension BlockContent.Layout: Hashable {}

public extension BlockContent {
    var isText: Bool {
        if case .text = self {
            return true
        }
        
        return false
    }
}
