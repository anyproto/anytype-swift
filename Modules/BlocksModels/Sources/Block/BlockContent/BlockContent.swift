import Foundation

public enum BlockContent: Hashable {
    case smartblock(BlockSmartblock)
    case text(BlockText)
    case file(BlockFile)
    case divider(BlockDivider)
    case bookmark(BlockBookmark)
    case link(BlockLink)
    case layout(BlockLayout)
    
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

public extension BlockContent {
    var isText: Bool {
        if case .text = self {
            return true
        }
        
        return false
    }
}
