import Foundation
import Services
import AnytypeCore

protocol ChatInputConverterProtocol: AnyObject, Sendable {
    func convert(message: NSAttributedString) -> ChatMessageContent
    func convert(content: ChatMessageContent, spaceId: String) async -> SafeNSAttributedString
}

final class ChatInputConverter: ChatInputConverterProtocol, Sendable {
    
    private let mentionObjectsService: any MentionObjectsServiceProtocol = Container.shared.mentionObjectsService()
    
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
    
    func convert(content: ChatMessageContent, spaceId: String) async -> SafeNSAttributedString {
        let message = NSMutableAttributedString(string: content.text)
        
        for mark in content.marks.reversed() {
            let nsRange = NSRange(mark.range)

            switch mark.type {
            case .strikethrough:
                message.addAttribute(.chatStrikethrough, value: true, range: nsRange)
            case .keyboard:
                message.addAttribute(.chatKeyboard, value: true, range: nsRange)
            case .italic:
                message.addAttribute(.chatItalic, value: true, range: nsRange)
            case .bold:
                message.addAttribute(.chatBold, value: true, range: nsRange)
            case .underscored:
                message.addAttribute(.chatUnderscored, value: true, range: nsRange)
            case .link:
                if let link = URL(string: mark.param) {
                    message.addAttribute(.chatLinkToURL, value: link, range: nsRange)
                }
            case .object:
                message.addAttribute(.chatLinkToObject, value: mark.param, range: nsRange)
            case .mention:
                do {
                    let mention = try await mentionObjectsService.searchMentionById(spaceId: spaceId, objectId: mark.param)
                    message.addAttribute(.chatMention, value: mention, range: nsRange)
                } catch {}
            case .UNRECOGNIZED, .textColor, .backgroundColor, .emoji:
                break
            }
        }
        
        return message.sendable()
    }
}

extension Container {
    var chatInputConverter: Factory<any ChatInputConverterProtocol> {
        self { ChatInputConverter() }
    }
}
