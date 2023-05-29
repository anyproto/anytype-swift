import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Layout {
    var blockContent: BlockContent? {
        style.asModel.flatMap { .layout(.init(style: $0)) }
    }
}

extension BlockLayout {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .layout(.with {
            $0.style = style.asMiddleware
        })
    }
}
