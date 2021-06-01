import BlocksModels
import ProtobufMessages

/// Convert (Anytype_Model_Block.OneOf_Content) <-> (BlockType) for contentType `.link(_)`.
class ContentLinkConverter {
    func blockType(_ from: Anytype_Model_Block.Content.Link) -> BlockContent? {
        let fields = HashableConverter.dictionary(from.fields)
        return BlocksModelsParserLinkStyleConverter.asModel(from.style)
            .flatMap({.link(.init(targetBlockID: from.targetBlockID, style: $0, fields: fields))})
    }
    func middleware(_ from: BlockLink) -> Anytype_Model_Block.OneOf_Content {
        let fields = GoogleProtobufStructuresConverter.structure(from.fields)
        let style = BlocksModelsParserLinkStyleConverter.asMiddleware(from.style)
        return .link(
            .init(
                targetBlockID: from.targetBlockID,
                style: style,
                fields: fields
            )
        )
    }
}
