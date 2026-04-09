import Testing
import Foundation
import SwiftUI
import ProtobufMessages
import DeepLinks
@testable import Anytype

@Suite
struct DiscussionTextBuilderFontTests {

    private let builder = DiscussionTextBuilder()

    // MARK: - Body styles return .calloutRegular

    @Test
    func paragraph_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .paragraph) == .calloutRegular)
    }

    @Test
    func description_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .description_) == .calloutRegular)
    }

    @Test
    func toggle_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .toggle) == .calloutRegular)
    }

    @Test
    func numbered_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .numbered) == .calloutRegular)
    }

    @Test
    func marked_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .marked) == .calloutRegular)
    }

    @Test
    func checkbox_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .checkbox) == .calloutRegular)
    }

    @Test
    func quote_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .quote) == .calloutRegular)
    }

    @Test
    func callout_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .callout) == .calloutRegular)
    }

    // MARK: - Heading styles return correct fonts

    @Test
    func header1_returnsTitle() {
        #expect(builder.anytypeFont(for: .header1) == .title)
    }

    @Test
    func titleStyle_returnsTitle() {
        #expect(builder.anytypeFont(for: .title) == .title)
    }

    @Test
    func header2_returnsHeading() {
        #expect(builder.anytypeFont(for: .header2) == .heading)
    }

    @Test
    func header3_returnsSubheading() {
        #expect(builder.anytypeFont(for: .header3) == .subheading)
    }

    @Test
    func header4_returnsSubheading() {
        #expect(builder.anytypeFont(for: .header4) == .subheading)
    }
}

// MARK: - Mark Styling Tests

@Suite(.serialized)
struct DiscussionTextBuilderMarkTests {

    private let builder: DiscussionTextBuilder

    init() {
        Container.shared.deepLinkParser.register { MockDeepLinkParser() }
        builder = DiscussionTextBuilder()
    }

    // MARK: - Link mark

    @Test
    func linkMark_setsForegroundColorToAccent() {
        var mark = Anytype_Model_Block.Content.Text.Mark()
        mark.type = .link
        mark.param = "https://example.com"
        mark.range = .with { $0.from = 0; $0.to = 5 }

        let result = builder.makeAttributedString(
            text: "hello world",
            marks: [mark],
            style: .paragraph,
            spaceId: "space1",
            position: .left
        )

        let runs = Array(result.runs)
        let linkRun = runs.first { $0.link != nil }
        #expect(linkRun != nil)
        #expect(linkRun?.foregroundColor == UIColor.Control.accent100.suColor)
    }

    @Test
    func linkMark_doesNotSetUnderline() {
        var mark = Anytype_Model_Block.Content.Text.Mark()
        mark.type = .link
        mark.param = "https://example.com"
        mark.range = .with { $0.from = 0; $0.to = 5 }

        let result = builder.makeAttributedString(
            text: "hello world",
            marks: [mark],
            style: .paragraph,
            spaceId: "space1",
            position: .left
        )

        let nsAttrString = NSAttributedString(result)
        var hasUnderline = false
        nsAttrString.enumerateAttribute(.underlineStyle, in: NSRange(location: 0, length: 5)) { value, _, _ in
            if let style = value as? Int, style != 0 {
                hasUnderline = true
            }
        }
        #expect(!hasUnderline)
    }

    // MARK: - Object mark

    @Test
    func objectMark_setsForegroundColorToAccent() {
        var mark = Anytype_Model_Block.Content.Text.Mark()
        mark.type = .object
        mark.param = "object123"
        mark.range = .with { $0.from = 0; $0.to = 5 }

        let result = builder.makeAttributedString(
            text: "hello world",
            marks: [mark],
            style: .paragraph,
            spaceId: "space1",
            position: .left
        )

        let runs = Array(result.runs)
        let linkRun = runs.first { $0.link != nil }
        #expect(linkRun != nil)
        #expect(linkRun?.foregroundColor == UIColor.Control.accent100.suColor)
    }

    // MARK: - Mention mark

    @Test
    func mentionMark_setsForegroundColorToAccent() {
        var mark = Anytype_Model_Block.Content.Text.Mark()
        mark.type = .mention
        mark.param = "user456"
        mark.range = .with { $0.from = 0; $0.to = 5 }

        let result = builder.makeAttributedString(
            text: "hello world",
            marks: [mark],
            style: .paragraph,
            spaceId: "space1",
            position: .left
        )

        let runs = Array(result.runs)
        let linkRun = runs.first { $0.link != nil }
        #expect(linkRun != nil)
        #expect(linkRun?.foregroundColor == UIColor.Control.accent100.suColor)
    }
}

// MARK: - Mock

private final class MockDeepLinkParser: DeepLinkParserProtocol {
    func parse(url: URL) -> DeepLink? { nil }
    func createUrl(deepLink: DeepLink, scheme: DeepLinkScheme) -> URL? {
        URL(string: "anytype://mock")
    }
}
