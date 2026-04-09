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
