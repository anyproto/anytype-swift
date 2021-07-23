import ProtobufMessages
import BlocksModels

class ContentDividerConverter {
    func blockType(_ from: Anytype_Model_Block.Content.Div) -> BlockContent? {
        BlocksModelsParserOtherDividerStyleConverter.asModel(from.style).flatMap({ .divider(.init(style: $0)) })
    }
    
    func middleware(_ from: BlockDivider) -> Anytype_Model_Block.OneOf_Content {
        let style = BlocksModelsParserOtherDividerStyleConverter.asMiddleware(from.style)
        return .div(.init(style: style))
    }
}
