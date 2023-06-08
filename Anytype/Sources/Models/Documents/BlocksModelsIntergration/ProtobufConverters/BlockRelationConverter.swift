import ProtobufMessages
import BlocksModels

extension Anytype_Model_Block.Content.Relation {
    var blockContent: BlockContent {
        .relation(
            BlockRelation(key: key)
        )
    }
}

extension BlockRelation {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .relation(.with {
            $0.key = key
        })
    }
}
