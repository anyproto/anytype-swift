
public enum BlockContentType: Hashable {
    case smartblock(BlockSmartblock.Style)
    case text(BlockText.Style)
    case file(FileContentType)
    case divider(BlockDivider.Style)
    case bookmark(BlockBookmark.Style)
    case link(BlockLink.Style)
    case layout(BlockLayout.Style)
    case featuredRelations
    case relation(key: String)
    case dataView

    public var style: String {
        switch self {
        case let .smartblock(style):
            return String(describing: style)
        case let .text(style):
            return String(describing: style)
        case let .file(style):
            return String(describing: style)
        case let .divider(style):
            return String(describing: style)
        case let .bookmark(style):
            return String(describing: style)
        case let .link(style):
            return String(describing: style)
        case let .layout(style):
            return String(describing: style)
        case .featuredRelations:
            return "featuredRelations"
        case let .relation(key):
            return "relationBlock \(key)"
        case .dataView:
            return "dataView"
        }
    }
}

extension BlockContentType {
    public static var allTextTypes: [BlockContentType] {
        BlockText.Style.allCases.map { BlockContentType.text($0) }
    }
}
