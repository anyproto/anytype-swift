import BlocksModels
import ProtobufMessages

class ContentTextConverter {
    
    func blockType(_ from: Anytype_Model_Block.Content.Text) -> BlockContent? {
        return BlocksModelsParserTextContentTypeConverter.asModel(from.style).flatMap {
            typealias Text = BlockContent.Text
            let attributedString = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asModel(
                text: from.text,
                marks: from.marks,
                style: from.style
            )
            let textContent: Text = .init(
                attributedText: attributedString, color: from.color, contentType: $0, checked: from.checked
            )
            return .text(textContent)
        }
    }
    
func middleware(_ from: BlockContent.Text) -> Anytype_Model_Block.OneOf_Content {
        let style = BlocksModelsParserTextContentTypeConverter.asMiddleware(from.contentType)
        return .text(
            .init(
                text: from.attributedText.string,
                style: style,
                marks: MiddlewareModelsModule.Parsers.Text.AttributedText.Converter.asMiddleware(
                    attributedText: from.attributedText
                ).marks,
                checked: from.checked,
                color: from.color
            )
        )
    }
}
