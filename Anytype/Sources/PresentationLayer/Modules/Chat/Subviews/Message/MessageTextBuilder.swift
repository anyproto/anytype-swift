import Services
import SwiftUI
import AnytypeCore
import DeepLinks

protocol MessageTextBuilderProtocol: Sendable {
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition, font: AnytypeFont) -> NSAttributedString
    func makeMessaeWithoutStyle(content: ChatMessageContent) -> String
}

extension MessageTextBuilderProtocol {
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition) -> NSAttributedString {
        makeMessage(content: content, spaceId: spaceId, position: position, font: .chatText)
    }
}

struct MessageTextBuilder: MessageTextBuilderProtocol, Sendable {
    
    private let deepLinkParser: any DeepLinkParserProtocol = Container.shared.deepLinkParser()
    
    func makeMessage(content: ChatMessageContent, spaceId: String, position: MessageHorizontalPosition, font: AnytypeFont) -> NSAttributedString {
        var message = AttributedString(content.text)
        
        var attributes = AttributeContainer()
        
        attributes.uiKit.font = UIKitFontBuilder.uiKitFont(font: font)
        attributes.uiKit.kern = font.config.kern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = font.lineHeightMultiple
        attributes.uiKit.paragraphStyle = paragraphStyle
        
        let textColor = position.isRight ? UIColor.Text.white : UIColor.Text.primary
        attributes.uiKit.foregroundColor = textColor
        let underlineColor = textColor.withAlphaComponent(0.3)
        attributes.uiKit.underlineColor = underlineColor
        
        message.setAttributes(attributes)
        
        for mark in content.marks.reversed() {
            let nsRange = NSRange(mark.range)
            guard let range = Range(nsRange, in: message) else {
                continue
            }
            
            switch mark.type {
            case .strikethrough:
                message[range].uiKit.strikethroughStyle = .single
            case .keyboard:
                message[range].uiKit.font = UIFont.code
            case .italic:
                message[range].uiKit.font = message[range].uiKit.font?.italic
            case .bold:
                message[range].uiKit.font = message[range].uiKit.font?.semibold
            case .underscored:
                message[range].uiKit.underlineStyle = .single
            case .link:
                message[range].uiKit.underlineStyle = .single
//                if let link = URL(string: mark.param) {
//                    message[range].uiKit.link = link
//                }
            case .object:
                message[range].uiKit.underlineStyle = .single
//                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
//                    message[range].uiKit.link = linkToObject
//                }
            case .textColor:
                message[range].uiKit.foregroundColor = MiddlewareColor(rawValue: mark.param).map { UIColor.Dark.uiColor(from: $0) }
            case .backgroundColor:
                message[range].uiKit.backgroundColor = MiddlewareColor(rawValue: mark.param).map { UIColor.VeryLight.uiColor(from: $0) }
            case .mention:
                message[range].uiKit.underlineStyle = .single
//                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
//                    message[range].uiKit.link = linkToObject
//                }
            case .emoji:
                message.replaceSubrange(range, with: AttributedString(mark.param, attributes: attributes))
            case .UNRECOGNIZED(let int):
                anytypeAssertionFailure("Undefined text attribute", info: ["value": int.description, "param": mark.param])
                break
            }
        }
        
        return NSAttributedString(message.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func makeMessaeWithoutStyle(content: ChatMessageContent) -> String {
        makeMessage(content: content, spaceId: "", position: .right).string
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
