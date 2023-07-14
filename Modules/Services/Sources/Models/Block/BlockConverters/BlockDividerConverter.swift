import ProtobufMessages

public extension Anytype_Model_Block.Content.Div {
    var blockContent: BlockContent? {
        BlockDivider(self).flatMap { .divider($0) }
    }
}

public extension BlockDivider {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .div(.with {
            $0.style = style.asMiddleware
        })
    }
}
