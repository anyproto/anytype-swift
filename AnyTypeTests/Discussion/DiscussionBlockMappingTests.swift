import Testing
import Foundation
import Services
import ProtobufMessages
@testable import Anytype

@Suite
struct DiscussionBlockMappingTests {

    private let textBuilder = StubDiscussionTextBuilder()
    private let embedBuilder = StubEmbedContentDataBuilder()

    // MARK: - Helpers

    private func makeChatMessage(blocks: [Anytype_Model_ChatMessage.MessageBlock]) -> ChatMessage {
        var msg = ChatMessage()
        msg.blocks = blocks
        return msg
    }

    private func makeTextBlock(text: String, style: Anytype_Model_Block.Content.Text.Style) -> Anytype_Model_ChatMessage.MessageBlock {
        var textContent = Anytype_Model_ChatMessage.MessageBlockText()
        textContent.text = text
        textContent.style = style

        var block = Anytype_Model_ChatMessage.MessageBlock()
        block.content = .text(textContent)
        return block
    }

    // MARK: - Header mapping

    @Test
    func header1_mapsToTitle() {
        let block = makeTextBlock(text: "Title text", style: .header1)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .title(let id, _) = result[0] {
            #expect(id == 0)
        } else {
            Issue.record("Expected .title, got \(result[0])")
        }
    }

    @Test
    func titleStyle_mapsToTitle() {
        let block = makeTextBlock(text: "Title text", style: .title)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .title = result[0] {
            // pass
        } else {
            Issue.record("Expected .title, got \(result[0])")
        }
    }

    @Test
    func header2_mapsToHeading() {
        let block = makeTextBlock(text: "Heading text", style: .header2)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .heading(let id, _) = result[0] {
            #expect(id == 0)
        } else {
            Issue.record("Expected .heading, got \(result[0])")
        }
    }

    @Test
    func header3_mapsToSubheading() {
        let block = makeTextBlock(text: "Subheading text", style: .header3)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .subheading(let id, _) = result[0] {
            #expect(id == 0)
        } else {
            Issue.record("Expected .subheading, got \(result[0])")
        }
    }

    @Test
    func header4_mapsToSubheading() {
        let block = makeTextBlock(text: "Subheading text", style: .header4)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .subheading = result[0] {
            // pass
        } else {
            Issue.record("Expected .subheading, got \(result[0])")
        }
    }

    @Test
    func paragraph_mapsToText() {
        let block = makeTextBlock(text: "Body text", style: .paragraph)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .text = result[0] {
            // pass
        } else {
            Issue.record("Expected .text, got \(result[0])")
        }
    }

    @Test
    func description_mapsToText() {
        let block = makeTextBlock(text: "Desc text", style: .description_)
        let msg = makeChatMessage(blocks: [block])

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 1)
        if case .text = result[0] {
            // pass
        } else {
            Issue.record("Expected .text, got \(result[0])")
        }
    }

    // MARK: - Numbered counter

    @Test
    func numberedBlocks_counterIncrementsSequentially() {
        let blocks = [
            makeTextBlock(text: "First", style: .numbered),
            makeTextBlock(text: "Second", style: .numbered),
            makeTextBlock(text: "Third", style: .numbered),
        ]
        let msg = makeChatMessage(blocks: blocks)

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 3)
        if case .numbered(_, _, let n1) = result[0] { #expect(n1 == 1) }
        if case .numbered(_, _, let n2) = result[1] { #expect(n2 == 2) }
        if case .numbered(_, _, let n3) = result[2] { #expect(n3 == 3) }
    }

    @Test
    func numberedBlocks_counterResetsAfterNonNumbered() {
        let blocks = [
            makeTextBlock(text: "First", style: .numbered),
            makeTextBlock(text: "Second", style: .numbered),
            makeTextBlock(text: "Break", style: .paragraph),
            makeTextBlock(text: "Restart", style: .numbered),
        ]
        let msg = makeChatMessage(blocks: blocks)

        let result = msg.resolvedDiscussionBlocks(
            spaceId: "space1",
            position: .left,
            textBuilder: textBuilder,
            embedContentDataBuilder: embedBuilder
        )

        #expect(result.count == 4)
        if case .numbered(_, _, let n1) = result[0] { #expect(n1 == 1) }
        if case .numbered(_, _, let n2) = result[1] { #expect(n2 == 2) }
        if case .text = result[2] { /* pass */ } else { Issue.record("Expected .text") }
        if case .numbered(_, _, let n3) = result[3] { #expect(n3 == 1) }
    }
}

// MARK: - Stubs

private final class StubDiscussionTextBuilder: DiscussionTextBuilderProtocol, @unchecked Sendable {
    func makeAttributedString(
        text: String,
        marks: [Anytype_Model_Block.Content.Text.Mark],
        style: Anytype_Model_Block.Content.Text.Style,
        spaceId: String,
        position: MessageHorizontalPosition
    ) -> AttributedString {
        AttributedString(text)
    }
}

private final class StubEmbedContentDataBuilder: EmbedContentDataBuilderProtocol, @unchecked Sendable {
    func build(from block: BlockLatex) -> EmbedContentData {
        EmbedContentData(icon: block.processor.icon, processorName: block.processor.name, hasContent: false, url: nil)
    }
}
