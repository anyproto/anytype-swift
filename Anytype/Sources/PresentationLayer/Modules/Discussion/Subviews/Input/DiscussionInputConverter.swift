import Foundation
import Services

protocol DiscussionInputConverterProtocol: AnyObject {
    func convert(message: NSAttributedString) -> ChatMessageContent
}

final class DiscussionInputConverter: DiscussionInputConverterProtocol {
    
    func convert(message: NSAttributedString) -> ChatMessageContent {
        
        var chatMessage = ChatMessageContent()
        chatMessage.text = message.string
        
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .discussionBold, middlewareStyle: .bold))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .discussionItalic, middlewareStyle: .italic))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .discussionKeyboard, middlewareStyle: .keyboard))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .discussionStrikethrough, middlewareStyle: .strikethrough))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .discussionUnderscored, middlewareStyle: .underscored))
        chatMessage.marks.append(contentsOf: convertMentionStyle(message: message))
        
        return chatMessage
    }
    
    private func convertBoolStyle(
        message: NSAttributedString,
        attribute: NSAttributedString.Key,
        middlewareStyle: BlockContentTextMarkType
    ) -> [BlockContentTextMark] {
        
        var marks = [BlockContentTextMark]()
        
        message.enumerateAttribute(attribute, in: NSRange(location: 0, length: message.length), options: []) { value, range, res in
            guard let value = value as? Bool, value else { return }
            var mark = BlockContentTextMark()
            mark.range = range.asMiddleware
            mark.type = middlewareStyle
            
            marks.append(mark)
        }
        
        return marks
    }
    
    private func convertMentionStyle(
        message: NSAttributedString
    ) -> [BlockContentTextMark] {
        
        var marks = [BlockContentTextMark]()
        
        message.enumerateAttribute(.discussionMention, in: NSRange(location: 0, length: message.length), options: []) { value, range, res in
            guard let value = value as? MentionObject else { return }
            var mark = BlockContentTextMark()
            mark.range = range.asMiddleware
            mark.type = .mention
            mark.param = value.id
            
            marks.append(mark)
        }
        
        return marks
    }
}

extension Container {
    var discussionInputConverter: Factory<any DiscussionInputConverterProtocol> {
        self { DiscussionInputConverter() }
    }
}
