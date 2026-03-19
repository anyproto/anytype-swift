import ProtobufMessages

public enum BlockContentType: Hashable {
    case smartblock(BlockSmartblock.Style)
    case text(BlockText.Style)
    case file(FileBlockContentData)
    case divider(BlockDivider.Style)
    case bookmark(BlockBookmark.Style)
    case link(BlockLink.Appearance)
    case layout(BlockLayout.Style)
    case featuredRelations
    case relation(key: String)
    case dataView
    case tableOfContents
    case table
    case tableColumn
    case tableRow
    case widget(BlockWidget.Layout)
    case chat
    case embed
}

extension BlockContentType {
    public static var allTextTypes: [BlockContentType] {
        BlockText.Style.allCases.map { BlockContentType.text($0) }
    }
}
