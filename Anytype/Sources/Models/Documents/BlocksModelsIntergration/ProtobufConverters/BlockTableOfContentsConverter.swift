import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.TableOfContents {
    var blockContent: BlockContent {
        return .tableOfContents(BlockTableOfContents())
    }
}

extension BlockTableOfContents {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        return .tableOfContents(Anytype_Model_Block.Content.TableOfContents())
    }
}
