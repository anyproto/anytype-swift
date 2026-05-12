import Services
import SwiftUI
import AnytypeCore
import DeepLinks
import ProtobufMessages

protocol DiscussionTextBuilderProtocol: Sendable {
    func makeAttributedString(
        text: String,
        marks: [Anytype_Model_Block.Content.Text.Mark],
        style: Anytype_Model_Block.Content.Text.Style,
        spaceId: String,
        position: MessageHorizontalPosition
    ) -> AttributedString
}

struct DiscussionTextBuilder: DiscussionTextBuilderProtocol, Sendable {

    private let deepLinkParser: any DeepLinkParserProtocol = Container.shared.deepLinkParser()

    func makeAttributedString(
        text: String,
        marks: [Anytype_Model_Block.Content.Text.Mark],
        style: Anytype_Model_Block.Content.Text.Style,
        spaceId: String,
        position: MessageHorizontalPosition
    ) -> AttributedString {
        let font = anytypeFont(for: style)
        var message = AttributedString(text)

        message.font = AnytypeFontBuilder.font(anytypeFont: font)
        message.kern = font.config.kern
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = font.lineHeightMultiple
        message.paragraphStyle = paragraphStyle

        let textColor = position.isRight ? UIColor.Text.white : UIColor.Text.primary
        message.foregroundColor = textColor.suColor
        let underlineColor = textColor.withAlphaComponent(0.3)
        message.uiKit.underlineColor = underlineColor

        for mark in marks.reversed() {
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
                if let link = URL(string: mark.param) {
                    message[range].link = link
                }
                message[range].foregroundColor = UIColor.Control.accent100.suColor
            case .object:
                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message[range].link = linkToObject
                }
                message[range].foregroundColor = UIColor.Control.accent100.suColor
            case .textColor:
                message[range].foregroundColor = MiddlewareColor(rawValue: mark.param).map { Color.Dark.color(from: $0) }
            case .backgroundColor:
                message[range].backgroundColor = MiddlewareColor(rawValue: mark.param).map { Color.Light.color(from: $0) }
            case .mention:
                if let linkToObject = createLinkToObject(mark.param, spaceId: spaceId) {
                    message[range].link = linkToObject
                }
                message[range].foregroundColor = UIColor.Control.accent100.suColor
            case .emoji:
                message.replaceSubrange(range, with: AttributedString(mark.param))
            case .UNRECOGNIZED(let int):
                anytypeAssertionFailure("Undefined text attribute", info: ["value": int.description, "param": mark.param])
                break
            }
        }

        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func anytypeFont(for style: Anytype_Model_Block.Content.Text.Style) -> AnytypeFont {
        switch style {
        case .header1, .title:
            return .title
        case .header2:
            return .heading
        case .header3, .header4:
            return .subheading
        case .description_, .paragraph, .toggle, .numbered, .marked, .checkbox, .quote, .callout:
            return .calloutRegular
        default:
            return .calloutRegular
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
