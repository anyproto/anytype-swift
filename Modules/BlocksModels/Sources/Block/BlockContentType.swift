
public enum BlockContentType: Hashable {
    case smartblock(BlockContent.Smartblock.Style)
    case text(BlockText.ContentType)
    case file(BlockContent.File.ContentType)
    case divider(BlockContent.Divider.Style)
    case bookmark(BlockContent.Bookmark.TypeEnum)
    case link(BlockLink.Style)
    case layout(BlockContent.Layout.Style)
}
