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
        let blockFields = ObjectPreviewFields.createDefaultFieldsForBlockLink().asMiddleware()
        return .link(
            .init(targetBlockID: targetBlockID, style: style.asMiddleware, fields: .init(fields: blockFields))
        )
    }
}

extension ObjectPreviewFields {

    static func createDefaultFieldsForBlockLink() -> ObjectPreviewFields {
        .init(icon: .medium, layout: .text, withName: true, featuredRelationsIds: [])
    }
}
