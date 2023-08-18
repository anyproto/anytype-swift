import ProtobufMessages

public extension Anytype_Model_Block.Content.Relation {
    var blockContent: BlockContent {
        .relation(
            BlockRelation(key: key)
        )
    }
}

public extension BlockRelation {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .relation(.with {
            $0.key = key
        })
    }
}
