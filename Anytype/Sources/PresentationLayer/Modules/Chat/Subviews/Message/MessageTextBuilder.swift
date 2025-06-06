import Services
import SwiftUI
import AnytypeCore
import DeepLinks

protocol MessageTextBuilderProtocol: Sendable {
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition, font: AnytypeFont) -> AttributedString
    func makeMessaeWithoutStyle(content: ChatMessageContent) -> String
}

extension MessageTextBuilderProtocol {
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition) -> AttributedString {
        makeMessage(content: content, spaceId: spaceId, position: position, font: .chatText)
    }
}

struct MessageTextBuilder: MessageTextBuilderProtocol, Sendable {
    
    private let deepLinkParser: any DeepLinkParserProtocol = Container.shared.deepLinkParser()
    
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition, font: AnytypeFont) -> AttributedString {
        var message = AttributedString(content.text)
        
        message.font = AnytypeFontBuilder.font(anytypeFont: font)
        message.kern = font.config.kern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = font.lineHeightMultiple
        message.paragraphStyle = paragraphStyle
        
        let textColor = position.isRight ? UIColor.Text.white : UIColor.Text.primary
        message.foregroundColor = textColor.suColor
        let underlineColor = textColor.withAlphaComponent(0.3)
        message.uiKit.underlineColor = underlineColor
        
        for mark in content.marks.reversed() {
            let nsRange = NSRange(mark.range)
            guard let range = Range(nsRange, in: message) else {
                anytypeAssertionFailure("Out of range", info: ["range": nsRange.description, "textLenght": content.text.count.description])
                continue
            }
            
            switch mark.type {
            case .strikethrough:
                message[range].strikethroughStyle = .single
            case .keyboard:
                message[range].font = AnytypeFontBuilder.font(anytypeFont: .codeBlock)
            case .italic:
                message[range].font = message[range].font?.italic()
            case .bold:
                message[range].font = message[range].font?.bold()
            case .underscored:
                message[range].uiKit.underlineStyle = .single
            case .link:
                message[range].uiKit.underlineStyle = .single
                if let link = URL(string: mark.param) {
                    message[range].link = link
                }
            case .object:
                message[range].uiKit.underlineStyle = .single
                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message[range].link = linkToObject
                }
            case .textColor:
                message[range].foregroundColor = MiddlewareColor(rawValue: mark.param).map { Color.Dark.color(from: $0) }
            case .backgroundColor:
                message[range].backgroundColor = MiddlewareColor(rawValue: mark.param).map { Color.VeryLight.color(from: $0) }
            case .mention:
                message[range].uiKit.underlineStyle = .single
                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message[range].link = linkToObject
                }
            case .emoji:
                message.replaceSubrange(range, with: AttributedString(mark.param))
            case .UNRECOGNIZED(let int):
                anytypeAssertionFailure("Undefined text attribute", info: ["value": int.description, "param": mark.param])
                break
            }
        }
        
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func makeMessaeWithoutStyle(content: ChatMessageContent) -> String {
        NSAttributedString(makeMessage(content: content, spaceId: "", position: .right)).string
    }
    
    private func createLinkToObject(_ objectId: String, spaceId: String) -> URL? {
        return deepLinkParser.createUrl(
            deepLink: .object(objectId: objectId, spaceId: spaceId),
            scheme: .main
        )
    }
}

extension Container {
    var messageTextBuilder: Factory<any MessageTextBuilderProtocol> {
        self { MessageTextBuilder() }.shared
    }
}
