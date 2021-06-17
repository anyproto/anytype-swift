import ProtobufMessages
import BlocksModels

enum BlocksModelsConverter {
    private static let contentObjectAsEmptyPage = ContentObjectAsEmptyPage()
    private static let contentLink = ContentLinkConverter()
    private static let contentText = ContentTextConverter()
    private static let contentFile = ContentFileConverter()
    private static let contentBookmark = ContentBookmarkConverter()
    private static let contentDivider = ContentDividerConverter()
    private static let contentLayout = ContentLayoutConverter()

    static func convert(middleware: Anytype_Model_Block.OneOf_Content) -> BlockContent? {
        switch middleware {
        case .smartblock(let data): return contentObjectAsEmptyPage.blockType(data)
        case .link(let data): return contentLink.blockType(data)
        case .text(let data): return contentText.blockType(data)
        case .file(let data): return contentFile.blockType(data)
        case .bookmark(let data): return contentBookmark.blockType(data)
        case .div(let data): return contentDivider.blockType(data)
        case .layout(let data): return contentLayout.blockType(data)
        
        case .featuredRelations: return nil
        case .relation: return nil
            
        default:
            assertionFailure("No converter for type: \(String(describing: middleware))")
            return nil
        }
    }

    static func convert(block: BlockContent) -> Anytype_Model_Block.OneOf_Content? {
        switch block {
        case .smartblock(let data): return contentObjectAsEmptyPage.middleware(data)
        case .link(let data): return contentLink.middleware(data)
        case .text(let data): return contentText.middleware(data)
        case .file(let data): return contentFile.middleware(data)
        case .bookmark(let data): return contentBookmark.middleware(data)
        case .divider(let data): return contentDivider.middleware(data)
        case .layout(let data): return contentLayout.middleware(data)
        }
    }
}
