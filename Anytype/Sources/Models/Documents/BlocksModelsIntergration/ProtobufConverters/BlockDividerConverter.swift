import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Div {
    var blockContent: BlockContent? {
        BlockDivider(self).flatMap { .divider($0) }
    }
}

extension BlockDivider {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .div(.init(style: style.asMiddleware))
    }
}
