import Foundation

public enum BlockContent: Hashable, Sendable {
    case smartblock(BlockSmartblock)
    case text(BlockText)
    case file(BlockFile)
    case divider(BlockDivider)
    case bookmark(BlockBookmark)
    case link(BlockLink)
    case layout(BlockLayout)
    case featuredRelations
    case relation(BlockProperty)
    case dataView(BlockDataview)
    case tableOfContents
    case table
    case tableColumn
    case tableRow(BlockTableRow)
    case widget(BlockWidget)
    case chat(BlockChat)
    case embed(BlockLatex)
    case unsupported
    
    public var type: BlockContentType {
        switch self {
        case let .smartblock(smartblock):
            return .smartblock(smartblock.style)
        case let .text(text):
            return .text(text.contentType)
        case let .file(file):
            return .file(
                FileBlockContentData(
                    contentType: file.contentType
                )
            )
        case let .divider(divider):
            return .divider(divider.style)
        case let .bookmark(bookmark):
            return .bookmark(bookmark.type)
        case let .link(content):
            return .link(content.appearance)
        case let .layout(layout):
            return .layout(layout.style)
        case .featuredRelations:
            return .featuredRelations
        case let .relation(content):
            return .relation(key: content.key)
        case .dataView:
            return .dataView
        case .tableOfContents:
            return .tableOfContents
        case .table:
            return .table
        case .tableColumn:
            return .tableColumn
        case .tableRow:
            return .tableRow
        case let .widget(widget):
            return .widget(widget.layout)
        case .chat:
            return .chat
        case .embed:
            return .embed
        case .unsupported:
            return .text(.text)
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

    var isEmpty: Bool {
        switch self {
        case .text(let blockText):
            return blockText.text.isEmpty
        default:
            return false
        }
    }
    
    var isToggle: Bool {
        if case let .text(text) = self, text.contentType == .toggle {
            return true
        }
        
        return false
    }
}
