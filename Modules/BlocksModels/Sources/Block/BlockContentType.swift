
public enum BlockContentType: Hashable {
    case smartblock(BlockContent.Smartblock.Style)
    case text(BlockContent.Text.ContentType)
    case file(BlockContent.File.ContentType)
    case divider(BlockContent.Divider.Style)
    case bookmark(BlockContent.Bookmark.TypeEnum)
    case link(BlockContent.Link.Style)
    case layout(BlockContent.Layout.Style)
}
