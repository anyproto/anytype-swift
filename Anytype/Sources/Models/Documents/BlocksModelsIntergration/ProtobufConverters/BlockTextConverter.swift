import BlocksModels
import ProtobufMessages

extension BlockText {
    var asMiddleware: Anytype_Model_Block.OneOf_Content {
        .text(
            Anytype_Model_Block.Content.Text(
                text: text,
                style: contentType.asMiddleware,
                marks: marks,
                checked: checked,
                color: color?.rawValue ?? "",
                iconEmoji: iconEmoji,
                iconImage: iconImage
            )
        )
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
