import ProtobufMessages
import AnytypeCore

public enum BlocksModelsConverter: Sendable {
    public static func convert(
        middleware: Anytype_Model_Block.OneOf_Content
    ) -> BlockContent? {
        switch middleware {
        case .smartblock(let data): return data.blockContent
        case .link(let data): return data.blockContent
        case .text(let data): return data.blockContent
        case .file(let data): return data.blockContent
        case .bookmark(let data): return data.blockContent
        case .div(let data): return data.blockContent
        case .layout(let data): return data.blockContent
        case .featuredRelations: return .featuredRelations
        case .dataview(let data): return data.blockContent
        case .relation(let data): return data.blockContent
        case .tableOfContents: return .tableOfContents
        case .table: return BlockContent.table
        case .tableColumn: return BlockContent.tableColumn
        case .tableRow(let data): return data.blockContent
        case .widget(let data): return .widget(data)
        case .chat(let data): return .chat(data)
        case .latex(let data): return .embed(data)
        case .icon:
            return .unsupported
        }
    }

    public static func convert(block: BlockContent) -> Anytype_Model_Block.OneOf_Content? {
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
            anytypeAssertionFailure("Not suppoted converter from featuredRelations to middleware")
            return nil
        case .dataView(let data):
            return .dataview(data.asMiddleware)
        case .unsupported:
            anytypeAssertionFailure("Not suppoted converter from unsupported to middleware")
            return nil
        case .table:
            return .table(Anytype_Model_Block.Content.Table())
        case .tableRow(let data):
            return .tableRow(.with { $0.isHeader = data.isHeader })
        case .tableColumn:
            return .tableColumn(.init())
        case .widget:
            anytypeAssertionFailure("Not suppoted converter from widget to middleware")
            return nil
        case .chat:
            anytypeAssertionFailure("Not suppoted converter from chat to middleware")
            return nil
        case .embed:
            anytypeAssertionFailure("Not suppoted converter from embed to middleware")
            return nil
        }
    }
}

