import Services
import ProtobufMessages

extension BlockText {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .text(.with {
            $0.text = text
            $0.style = contentType.asMiddleware
            $0.marks = marks
            $0.checked = checked
            $0.color = color?.rawValue ?? ""
            $0.iconEmoji = iconEmoji
            $0.iconImage = iconImage
        })
    }
}

extension Anytype_Model_Block.Content.Text {
    
    var blockContent: BlockContent? {
        textContent.flatMap { .text($0) }
    }
    
    var textContent: BlockText? {
        BlockText.Style(style).flatMap { contentType in
            BlockText(
                text: text,
                marks: marks,
                color: MiddlewareColor(rawValue: color),
                contentType: contentType,
                checked: checked,
                number: 1,
                iconEmoji: iconEmoji,
                iconImage: iconImage
            )
        }
    }
}
