import ProtobufMessages
import BlocksModels
import AnytypeCore

enum BlocksModelsConverter {
    private static let contentObjectAsEmptyPage = ContentObjectAsEmptyPage()
    private static let contentBookmark = ContentBookmarkConverter()
    private static let contentDivider = ContentDividerConverter()
    private static let contentLayout = ContentLayoutConverter()
    
    static func convert(
        middleware: Anytype_Model_Block.OneOf_Content
    ) -> BlockContent? {
        switch middleware {
        case .smartblock(let data): return contentObjectAsEmptyPage.blockType(data)
        case .link(let data): return data.blockType
        case .text(let data): return data.blockContent
        case .file(let data): return data.blockType
        case .bookmark(let data): return contentBookmark.blockType(data)
        case .div(let data): return contentDivider.blockType(data)
        case .layout(let data): return contentLayout.blockType(data)
        case .featuredRelations: return .featuredRelations
        
        case .icon, .relation, .latex, .dataview:
            return .unsupported
        }
    }

    static func convert(block: BlockContent) -> Anytype_Model_Block.OneOf_Content? {
        switch block {
        case .smartblock(let data): return contentObjectAsEmptyPage.middleware(data)
        case .link(let data): return data.asMiddleware
        case .text(let data): return data.asMiddleware
        case .file(let data): return data.asMiddleware
        case .bookmark(let data): return contentBookmark.middleware(data)
        case .divider(let data): return contentDivider.middleware(data)
        case .layout(let data): return contentLayout.middleware(data)
        case .featuredRelations:
            anytypeAssertionFailure("Not suppoted converter from featuredRelations to middleware")
            return nil
        case .unsupported:
            anytypeAssertionFailure("Not suppoted converter from unsupported to middleware")
            return nil
        }
    }
}
