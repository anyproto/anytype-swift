import Testing
import Foundation
@testable import Anytype

@Suite
struct DiscussionBlockItemSpacingTests {

    // MARK: - topSpacing

    @Test
    func topSpacing_title_is20() {
        let item = DiscussionBlockItem.title(id: 0, content: AttributedString("Title"))
        #expect(item.topSpacing == 20)
    }

    @Test
    func topSpacing_heading_is16() {
        let item = DiscussionBlockItem.heading(id: 0, content: AttributedString("Heading"))
        #expect(item.topSpacing == 16)
    }

    @Test
    func topSpacing_subheading_is12() {
        let item = DiscussionBlockItem.subheading(id: 0, content: AttributedString("Subheading"))
        #expect(item.topSpacing == 12)
    }

    @Test
    func topSpacing_quote_is12() {
        let item = DiscussionBlockItem.quote(id: 0, content: AttributedString("Quote"))
        #expect(item.topSpacing == 12)
    }

    @Test
    func topSpacing_text_is8() {
        let item = DiscussionBlockItem.text(id: 0, content: AttributedString("Text"))
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_callout_is8() {
        let item = DiscussionBlockItem.callout(id: 0, content: AttributedString("Callout"))
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_checkbox_is8() {
        let item = DiscussionBlockItem.checkbox(id: 0, content: AttributedString("Check"), checked: false)
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_bulleted_is8() {
        let item = DiscussionBlockItem.bulleted(id: 0, content: AttributedString("Bullet"))
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_numbered_is8() {
        let item = DiscussionBlockItem.numbered(id: 0, content: AttributedString("Num"), number: 1)
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_toggle_is8() {
        let item = DiscussionBlockItem.toggle(id: 0, content: AttributedString("Toggle"))
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_divider_is8() {
        let item = DiscussionBlockItem.divider(id: 0)
        #expect(item.topSpacing == 8)
    }

    @Test
    func topSpacing_unsupported_is8() {
        let item = DiscussionBlockItem.unsupported(id: 0, blockName: "test")
        #expect(item.topSpacing == 8)
    }

    // MARK: - bottomSpacing

    @Test
    func bottomSpacing_quote_is12() {
        let item = DiscussionBlockItem.quote(id: 0, content: AttributedString("Quote"))
        #expect(item.bottomSpacing == 12)
    }

    @Test
    func bottomSpacing_text_is0() {
        let item = DiscussionBlockItem.text(id: 0, content: AttributedString("Text"))
        #expect(item.bottomSpacing == 0)
    }

    @Test
    func bottomSpacing_title_is0() {
        let item = DiscussionBlockItem.title(id: 0, content: AttributedString("Title"))
        #expect(item.bottomSpacing == 0)
    }

    @Test
    func bottomSpacing_heading_is0() {
        let item = DiscussionBlockItem.heading(id: 0, content: AttributedString("Heading"))
        #expect(item.bottomSpacing == 0)
    }

    @Test
    func bottomSpacing_subheading_is0() {
        let item = DiscussionBlockItem.subheading(id: 0, content: AttributedString("Subheading"))
        #expect(item.bottomSpacing == 0)
    }

    @Test
    func bottomSpacing_divider_is0() {
        let item = DiscussionBlockItem.divider(id: 0)
        #expect(item.bottomSpacing == 0)
    }

    @Test
    func bottomSpacing_bulleted_is0() {
        let item = DiscussionBlockItem.bulleted(id: 0, content: AttributedString("Bullet"))
        #expect(item.bottomSpacing == 0)
    }
}

// MARK: - DiscussionBlockSpacing tests

@Suite
struct DiscussionBlockSpacingTests {

    @Test
    func emptyBlocks_returnsEmptyPaddings() {
        let paddings = DiscussionBlockSpacing.topPaddings(for: [])
        #expect(paddings.isEmpty)
    }

    @Test
    func singleBlock_alwaysGets8() {
        let blocks: [DiscussionBlockItem] = [
            .title(id: 0, content: AttributedString("Title"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings == [8])
    }

    @Test
    func firstBlock_alwaysGets8_regardlessOfType() {
        // Title has topSpacing 20, but first block should always be 8
        let blocks: [DiscussionBlockItem] = [
            .title(id: 0, content: AttributedString("Title")),
            .text(id: 1, content: AttributedString("Text"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[0] == 8)
    }

    @Test
    func textToQuote_usesQuoteTopSpacing() {
        // text.bottomSpacing=0, quote.topSpacing=12 → max(12, 0)=12
        let blocks: [DiscussionBlockItem] = [
            .text(id: 0, content: AttributedString("Text")),
            .quote(id: 1, content: AttributedString("Quote"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 12)
    }

    @Test
    func quoteToText_usesQuoteBottomSpacing() {
        // quote.bottomSpacing=12, text.topSpacing=8 → max(8, 12)=12
        let blocks: [DiscussionBlockItem] = [
            .quote(id: 0, content: AttributedString("Quote")),
            .text(id: 1, content: AttributedString("Text"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 12)
    }

    @Test
    func textToTitle_usesTitleTopSpacing() {
        // text.bottomSpacing=0, title.topSpacing=20 → max(20, 0)=20
        let blocks: [DiscussionBlockItem] = [
            .text(id: 0, content: AttributedString("Text")),
            .title(id: 1, content: AttributedString("Title"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 20)
    }

    @Test
    func textToText_uses8() {
        // text.bottomSpacing=0, text.topSpacing=8 → max(8, 0)=8
        let blocks: [DiscussionBlockItem] = [
            .text(id: 0, content: AttributedString("A")),
            .text(id: 1, content: AttributedString("B"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 8)
    }

    @Test
    func quoteToQuote_uses12() {
        // quote.bottomSpacing=12, quote.topSpacing=12 → max(12, 12)=12
        let blocks: [DiscussionBlockItem] = [
            .quote(id: 0, content: AttributedString("A")),
            .quote(id: 1, content: AttributedString("B"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 12)
    }

    @Test
    func textTitleBullet_fullSequence() {
        let blocks: [DiscussionBlockItem] = [
            .text(id: 0, content: AttributedString("Text")),
            .title(id: 1, content: AttributedString("Title")),
            .bulleted(id: 2, content: AttributedString("Bullet"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        // First: always 8
        #expect(paddings[0] == 8)
        // text→title: max(20, 0)=20
        #expect(paddings[1] == 20)
        // title→bullet: max(8, 0)=8
        #expect(paddings[2] == 8)
    }

    @Test
    func textQuoteText_fullSequence() {
        let blocks: [DiscussionBlockItem] = [
            .text(id: 0, content: AttributedString("Text")),
            .quote(id: 1, content: AttributedString("Quote")),
            .text(id: 2, content: AttributedString("Text"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        // First: always 8
        #expect(paddings[0] == 8)
        // text→quote: max(12, 0)=12
        #expect(paddings[1] == 12)
        // quote→text: max(8, 12)=12
        #expect(paddings[2] == 12)
    }

    @Test
    func quoteToHeading_usesHeadingTopSpacing() {
        // quote.bottomSpacing=12, heading.topSpacing=16 → max(16, 12)=16
        let blocks: [DiscussionBlockItem] = [
            .quote(id: 0, content: AttributedString("Quote")),
            .heading(id: 1, content: AttributedString("Heading"))
        ]
        let paddings = DiscussionBlockSpacing.topPaddings(for: blocks)
        #expect(paddings[1] == 16)
    }
}
