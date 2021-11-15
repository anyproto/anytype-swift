import BlocksModels
import ProtobufMessages

extension Anytype_Model_Block.Content.Link {
    var blockContent: BlockContent? {
        style.asModel.flatMap {
            return .link(
                BlockLink(targetBlockID: targetBlockID, style: $0, fields: fields.fields)
            )
        }
    }
}

extension BlockLink {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        let fields = GoogleProtobufStructuresConverter.structure(fields)
        return .link(
            .init(targetBlockID: targetBlockID, style: style.asMiddleware, fields: fields)
        )
    }
}
