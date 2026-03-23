import Services
import SwiftUI
import AnytypeCore
import DeepLinks
import ProtobufMessages

protocol DiscussionTextBuilderProtocol: Sendable {
    func makeMessage(content: ResolvedDiscussionContent, spaceId: String, position: MessageHorizontalPosition) -> AttributedString
    func makeMessageWithoutStyle(content: ResolvedDiscussionContent) -> String
}

struct DiscussionTextBuilder: DiscussionTextBuilderProtocol, Sendable {

    private let deepLinkParser: any DeepLinkParserProtocol = Container.shared.deepLinkParser()

    func makeMessage(content: ResolvedDiscussionContent, spaceId: String, position: MessageHorizontalPosition) -> AttributedString {
        let baseFont: AnytypeFont = .chatText
        var message = AttributedString(content.content.text)

        message.font = AnytypeFontBuilder.font(anytypeFont: baseFont)
        message.kern = baseFont.config.kern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = baseFont.lineHeightMultiple
        message.paragraphStyle = paragraphStyle

        let textColor = position.isRight ? UIColor.Text.white : UIColor.Text.primary
        message.foregroundColor = textColor.suColor
        let underlineColor = textColor.withAlphaComponent(0.3)
        message.uiKit.underlineColor = underlineColor

        for mark in content.content.marks.reversed() {
            let nsRange = NSRange(mark.range)
            guard let range = Range(nsRange, in: message) else {
                continue
            }

            switch mark.type {
            case .strikethrough:
                message[range].strikethroughStyle = .single
            case .keyboard:
                message[range].font = AnytypeFontBuilder.font(anytypeFont: .codeBlock)
            case .italic:
                message[range].uiKit.obliqueness = CGFloat(0.2)
            case .bold:
                message[range].font = message[range].font?.weight(.semibold)
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
                message[range].backgroundColor = MiddlewareColor(rawValue: mark.param).map { Color.Light.color(from: $0) }
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

        // Apply block style fonts for headers/title
        for blockStyle in content.blockStyleRanges {
            guard let font = anytypeFont(for: blockStyle.style) else { continue }
            guard font != baseFont else { continue }
            guard let range = Range(blockStyle.range, in: message) else { continue }

            message[range].font = AnytypeFontBuilder.font(anytypeFont: font)
            message[range].kern = font.config.kern
            let styleParagraph = NSMutableParagraphStyle()
            styleParagraph.lineHeightMultiple = font.lineHeightMultiple
            message[range].paragraphStyle = styleParagraph
        }

        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func makeMessageWithoutStyle(content: ResolvedDiscussionContent) -> String {
        NSAttributedString(makeMessage(content: content, spaceId: "", position: .right)).string
    }

    private func anytypeFont(for style: Anytype_Model_Block.Content.Text.Style) -> AnytypeFont? {
        switch style {
        case .header1:
            return .title
        case .header2:
            return .heading
        case .header3, .header4:
            return .subheading
        case .title:
            return .title
        case .description_, .paragraph, .toggle, .numbered, .marked, .checkbox, .quote, .callout:
            return .chatText
        default:
            return nil
        }
    }

    private func createLinkToObject(_ objectId: String, spaceId: String) -> URL? {
        return deepLinkParser.createUrl(
            deepLink: .object(objectId: objectId, spaceId: spaceId),
            scheme: .main
        )
    }
}

extension Container {
    var discussionTextBuilder: Factory<any DiscussionTextBuilderProtocol> {
        self { DiscussionTextBuilder() }.shared
    }
}
