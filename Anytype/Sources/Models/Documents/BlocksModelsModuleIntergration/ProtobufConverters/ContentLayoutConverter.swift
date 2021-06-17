import ProtobufMessages
import BlocksModels

class ContentLayoutConverter {
    func blockType(_ from: Anytype_Model_Block.Content.Layout) -> BlockContent? {
        BlocksModelsParserLayoutStyleConverter.asModel(from.style).flatMap({ .layout(.init(style: $0)) })
    }
    
    func middleware(_ from: BlockContent.Layout) -> Anytype_Model_Block.OneOf_Content {
        let style = BlocksModelsParserLayoutStyleConverter.asMiddleware(from.style)
        return .layout(.init(style: style))
    }
}
