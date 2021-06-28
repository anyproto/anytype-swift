
public enum BlockContentType: Hashable {
    case smartblock(BlockSmartblock.Style)
    case text(BlockText.ContentType)
    case file(BlockFile.ContentType)
    case divider(BlockDivider.Style)
    case bookmark(BlockBookmark.TypeEnum)
    case link(BlockLink.Style)
    case layout(BlockLayout.Style)
}
