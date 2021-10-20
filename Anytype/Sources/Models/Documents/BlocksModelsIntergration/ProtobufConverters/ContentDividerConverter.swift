import ProtobufMessages
import BlocksModels

class ContentDividerConverter {
    func blockType(_ model: Anytype_Model_Block.Content.Div) -> BlockContent? {
        BlockDivider(model).flatMap { .divider($0) }
    }
    
    func middleware(_ from: BlockDivider) -> Anytype_Model_Block.OneOf_Content {
        return .div(.init(style: from.style.asMiddleware))
    }
}
