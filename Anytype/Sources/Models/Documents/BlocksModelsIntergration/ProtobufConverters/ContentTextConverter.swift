import BlocksModels
import ProtobufMessages

class ContentTextConverter {
    
    func blockContent(_ from: Anytype_Model_Block.Content.Text) -> BlockContent? {
        return textContent(from).flatMap { .text($0) }
    }
    
    func textContent(_ from: Anytype_Model_Block.Content.Text) -> BlockText? {
        return BlockTextContentTypeConverter.asModel(from.style).flatMap { contentType in
            let attributedString = AttributedTextConverter.asModel(
                text: from.text,
                marks: from.marks,
                style: from.style
            )
            
            return BlockText(
                attributedText: attributedString,
                color: MiddlewareColor(rawValue: from.color),
                contentType: contentType,
                checked: from.checked
            )
        }
    }
    
func middleware(_ from: BlockText) -> Anytype_Model_Block.OneOf_Content {
        let style = BlockTextContentTypeConverter.asMiddleware(from.contentType)
        return .text(
            Anytype_Model_Block.Content.Text(
                text: from.attributedText.string,
                style: style,
                marks: AttributedTextConverter.asMiddleware(
                    attributedText: from.attributedText
                ).marks,
                checked: from.checked,
                color: from.color?.rawValue ?? ""
            )
        )
    }
}
