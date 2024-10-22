import Foundation
import Services

protocol ChatInputConverterProtocol: AnyObject {
    func convert(message: NSAttributedString) -> ChatMessageContent
}

final class ChatInputConverter: ChatInputConverterProtocol {
    
    func convert(message: NSAttributedString) -> ChatMessageContent {
        
        var chatMessage = ChatMessageContent()
        chatMessage.text = message.string
        
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .chatBold, middlewareStyle: .bold))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .chatItalic, middlewareStyle: .italic))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .chatKeyboard, middlewareStyle: .keyboard))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .chatStrikethrough, middlewareStyle: .strikethrough))
        chatMessage.marks.append(contentsOf: convertBoolStyle(message: message, attribute: .chatUnderscored, middlewareStyle: .underscored))
        
        chatMessage.marks.append(contentsOf: convertAttribute(message: message, attribute: .chatMention, type: .mention, convert: { (value: MentionObject) in value.id }))
        chatMessage.marks.append(contentsOf: convertAttribute(message: message, attribute: .chatLinkToURL, type: .link, convert: { (value: URL) in value.absoluteString }))
        chatMessage.marks.append(contentsOf: convertAttribute(message: message, attribute: .chatLinkToObject, type: .object, convert: { (value: String) in value }))
                
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
    
    private func convertAttribute<T>(
        message: NSAttributedString,
        attribute: NSAttributedString.Key,
        type: BlockContentTextMarkType,
        convert: (T) -> String
    ) -> [BlockContentTextMark] {
        
        var marks = [BlockContentTextMark]()
        
        message.enumerateAttribute(attribute, in: NSRange(location: 0, length: message.length), options: []) { value, range, res in
            guard let value = value as? T else { return }
            var mark = BlockContentTextMark()
            mark.range = range.asMiddleware
            mark.type = type
            mark.param = convert(value)
            
            marks.append(mark)
        }
        
        return marks
    }
}

extension Container {
    var chatInputConverter: Factory<any ChatInputConverterProtocol> {
        self { ChatInputConverter() }
    }
}
