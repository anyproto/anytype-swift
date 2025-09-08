import Services
import SwiftUI
import AnytypeCore
import DeepLinks

protocol MessageTextBuilderProtocol: Sendable {
    func makeMessage(
        content: ChatMessageContent,
        spaceId: String,
        position: MessageHorizontalPosition,
        font: AnytypeFont,
        linkHandler: (@Sendable @MainActor (URL) -> Void)?
    ) -> NSAttributedString
    func makeMessaeWithoutStyle(content: ChatMessageContent, font: AnytypeFont) -> String
}

struct MessageTextBuilder: MessageTextBuilderProtocol, Sendable {
    
    private let deepLinkParser: any DeepLinkParserProtocol = Container.shared.deepLinkParser()
    
    func makeMessage(
        content: ChatMessageContent,
        spaceId: String,
        position: MessageHorizontalPosition,
        font: AnytypeFont,
        linkHandler: (@Sendable @MainActor (URL) -> Void)?
    ) -> NSAttributedString {
    
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = font.lineHeightMultiple
        
        let textColor = position.isRight ? UIColor.Text.white : UIColor.Text.primary
        let underlineColor = textColor.withAlphaComponent(0.3)
        let uiFont = UIKitFontBuilder.uiKitFont(font: font)
        let attributes: [NSAttributedString.Key : Any] = [
            .font: uiFont,
            .kern: font.config.kern,
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor,
            .underlineColor: underlineColor
        ]
        let message = NSMutableAttributedString(string: content.text, attributes: attributes)
        
        for mark in content.marks.reversed() {
            let nsRange = NSRange(mark.range)
            
            switch mark.type {
            case .strikethrough:
                message.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            case .keyboard:
                message.addAttribute(.font, value: UIFont.code, range: nsRange)
            case .italic:
                message.addAttribute(.font, value: uiFont.italic, range: nsRange)
            case .bold:
                message.addAttribute(.font, value: uiFont.semibold, range: nsRange)
            case .underscored:
                message.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            case .link:
                message.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                if let linkHandler, let link = URL(string: mark.param) {
                    message.addAttribute(.tapHandler, value: {
                        MainActor.assumeIsolated {
                            linkHandler(link)
                        }
                    }, range: nsRange)
                }
            case .object:
                message.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                if let linkHandler, let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message.addAttribute(.tapHandler, value: {
                        MainActor.assumeIsolated {
                            linkHandler(linkToObject)
                        }
                    }, range: nsRange)
                }
            case .textColor:
                if let color = MiddlewareColor(rawValue: mark.param).map({ UIColor.Dark.uiColor(from: $0) }) {
                    message.addAttribute(.foregroundColor, value: color, range: nsRange)
                }
            case .backgroundColor:
                if let color = MiddlewareColor(rawValue: mark.param).map({ UIColor.VeryLight.uiColor(from: $0) }) {
                    message.addAttribute(.backgroundColor, value: color, range: nsRange)
                }
            case .mention:
                message.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                if let linkHandler, let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message.addAttribute(.tapHandler, value: {
                        MainActor.assumeIsolated {
                            linkHandler(linkToObject)
                        }
                    }, range: nsRange)
                }
            case .emoji:
                let substring = NSAttributedString(string: mark.param, attributes: attributes)
                message.replaceCharacters(in: nsRange, with: substring)
            case .UNRECOGNIZED(let int):
                anytypeAssertionFailure("Undefined text attribute", info: ["value": int.description, "param": mark.param])
                break
            }
        }
        
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func makeMessaeWithoutStyle(content: ChatMessageContent, font: AnytypeFont) -> String {
        makeMessage(content: content, spaceId: "", position: .right, font: font, linkHandler: nil).string
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
