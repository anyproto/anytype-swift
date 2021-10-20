import BlocksModels
import ProtobufMessages

class ContentTextConverter {
    
    func blockContent(_ from: Anytype_Model_Block.Content.Text) -> BlockContent? {
        return textContent(from).flatMap { .text($0) }
    }
    
    func textContent(_ block: Anytype_Model_Block.Content.Text) -> BlockText? {
        return BlockText.Style(block.style).flatMap { contentType in
            return BlockText(
                text: block.text,
                marks: block.marks,
                color: MiddlewareColor(rawValue: block.color),
                contentType: contentType,
                checked: block.checked
            )
        }
    }
    
func middleware(_ block: BlockText) -> Anytype_Model_Block.OneOf_Content {
        return .text(
            Anytype_Model_Block.Content.Text(
                text: block.text,
                style: block.contentType.asMiddleware,
                marks: block.marks,
                checked: block.checked,
                color: block.color?.rawValue ?? ""
            )
        )
    }
}
