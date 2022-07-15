import ProtobufMessages
import BlocksModels
import AnytypeCore

enum BlocksModelsConverter {
    static func convert(
        middleware: Anytype_Model_Block.OneOf_Content
    ) -> BlockContent? {
        switch middleware {
        case .smartblock(let data): return data.blockContent
        case .link(let data): return data.blockContent
        case .text(let data): return data.blockContent
        case .file(let data): return data.blockContent
        case .bookmark(let data): return data.blockConten
        case .div(let data): return data.blockContent
        case .layout(let data): return data.blockContent
        case .featuredRelations: return .featuredRelations
        case .dataview(let data): return data.blockContent
        case .relation(let data): return data.blockContent
        case .tableOfContents: return FeatureFlags.isTableOfContentsAvailable ? .tableOfContents : .unsupported
        case .table: return BlockContent.table
        case .tableColumn: return BlockContent.tableColumn
        case .tableRow: return BlockContent.tableRow
        case .icon, .latex:
            return .unsupported
        case .table, .tableRow, .tableColumn:
            return .unsupported
        }
    }

    static func convert(block: BlockContent) -> Anytype_Model_Block.OneOf_Content? {
        switch block {
        case .smartblock(let data): return data.asMiddleware
        case .link(let data): return data.asMiddleware
        case .text(let data): return data.asMiddleware
        case .file(let data): return data.asMiddleware
        case .bookmark(let data): return data.asMiddleware
        case .divider(let data): return data.asMiddleware
        case .layout(let data): return data.asMiddleware
        case .relation(let data): return data.asMiddleware
        case .tableOfContents: return .tableOfContents(Anytype_Model_Block.Content.TableOfContents())
        case .featuredRelations:
            anytypeAssertionFailure(
                "Not suppoted converter from featuredRelations to middleware",
                domain: .blocksConverter
            )
            return nil
        case .dataView:
            anytypeAssertionFailure(
                "Not suppoted converter from dataview to middleware",
                domain: .blocksConverter
            )
            return nil
        case .unsupported:
            anytypeAssertionFailure(
                "Not suppoted converter from unsupported to middleware",
                domain: .blocksConverter
            )
            return nil
        case .table, .tableRow, .tableColumn:
            anytypeAssertionFailure(
                "Not suppoted",
                domain: .blocksConverter
            )
            return nil
        }
    }
}

