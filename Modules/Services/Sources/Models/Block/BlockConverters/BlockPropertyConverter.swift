import ProtobufMessages

public extension Anytype_Model_Block.Content.Relation {
    var blockContent: BlockContent {
        .relation(
            BlockProperty(key: key)
        )
    }
}

public extension BlockProperty {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .relation(.with {
            $0.key = key
        })
    }
}
