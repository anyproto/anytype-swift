import Services
import Foundation
import ProtobufMessages

extension ChatMessage {

    func resolvedDiscussionBlocks(
        spaceId: String,
        position: MessageHorizontalPosition,
        textBuilder: any DiscussionTextBuilderProtocol,
        embedContentDataBuilder: any EmbedContentDataBuilderProtocol,
        attachmentDetails: [String: ObjectDetails] = [:]
    ) -> [DiscussionBlockItem] {
        guard !blocks.isEmpty else {
            let content = textBuilder.makeAttributedString(
                text: message.text,
                marks: message.marks,
                style: .paragraph,
                spaceId: spaceId,
                position: position
            )
            if content.characters.isEmpty { return [] }
            return [.text(id: 0, content: content)]
        }

        var result: [DiscussionBlockItem] = []
        var numberedCounter = 0

        for (index, block) in blocks.enumerated() {
            switch block.content {
            case .text(let textBlock):
                if textBlock.text == "---", textBlock.marks.isEmpty {
                    result.append(.divider(id: index))
                    continue
                }

                let content = textBuilder.makeAttributedString(
                    text: textBlock.text,
                    marks: textBlock.marks,
                    style: textBlock.style,
                    spaceId: spaceId,
                    position: position
                )

                if textBlock.style != .numbered {
                    numberedCounter = 0
                }

                switch textBlock.style {
                case .paragraph, .description_:
                    result.append(.text(id: index, content: content))
                case .header1, .title:
                    result.append(.title(id: index, content: content))
                case .header2:
                    result.append(.heading(id: index, content: content))
                case .header3, .header4:
                    result.append(.subheading(id: index, content: content))
                case .quote:
                    result.append(.quote(id: index, content: content))
                case .callout:
                    result.append(.callout(id: index, content: content))
                case .checkbox:
                    result.append(.checkbox(id: index, content: content, checked: textBlock.checked))
                case .marked:
                    result.append(.bulleted(id: index, content: content))
                case .numbered:
                    numberedCounter += 1
                    result.append(.numbered(id: index, content: content, number: numberedCounter))
                case .toggle:
                    result.append(.toggle(id: index, content: content))
                case .code, .toggleHeader1, .toggleHeader2, .toggleHeader3, .UNRECOGNIZED:
                    result.append(.unsupported(id: index, blockName: "style:\(textBlock.style)"))
                }

            case .link(let linkBlock):
                let targetId = linkBlock.targetObjectID
                guard let details = attachmentDetails[targetId] else {
                    result.append(.unsupported(id: index, blockName: "link:\(linkBlock.type)"))
                    break
                }
                let attachmentInfo = MessageAttachmentDetails(details: details)
                switch linkBlock.type {
                case .image:
                    result.append(.image(id: index, details: attachmentInfo))
                case .file:
                    if details.resolvedLayoutValue == .video {
                        result.append(.video(id: index, details: attachmentInfo))
                    } else {
                        result.append(.file(id: index, details: attachmentInfo))
                    }
                case .object:
                    result.append(.linkObject(id: index, details: attachmentInfo))
                case .bookmark:
                    result.append(.bookmark(id: index, details: details))
                case .UNRECOGNIZED:
                    result.append(.unsupported(id: index, blockName: "link:unrecognized"))
                }
            case .embed(let embedBlock):
                var block = BlockLatex()
                block.text = embedBlock.text
                block.processor = embedBlock.processor
                let data = embedContentDataBuilder.build(from: block)
                result.append(.embed(id: index, data: data))
            case .editorQuote:
                result.append(.unsupported(id: index, blockName: "editorQuote"))
            case .messageQuote:
                result.append(.unsupported(id: index, blockName: "messageQuote"))
            case nil:
                result.append(.unsupported(id: index, blockName: "unknown"))
            }
        }

        return result
    }

    /// Combined text+marks for the edit input converter (needs the legacy flat format)
    func combinedMessageContent() -> ChatMessageContent {
        guard !blocks.isEmpty else { return message }

        var content = ChatMessageContent()
        var combinedText = ""
        var combinedMarks: [Anytype_Model_Block.Content.Text.Mark] = []

        for block in blocks {
            if !combinedText.isEmpty {
                combinedText += "\n"
            }
            let textOffset = Int32(combinedText.utf16.count)

            if case .text(let textBlock) = block.content {
                combinedText += textBlock.text
                for var mark in textBlock.marks {
                    mark.range.from += textOffset
                    mark.range.to += textOffset
                    combinedMarks.append(mark)
                }
            }
        }

        content.text = combinedText
        content.marks = combinedMarks
        return content
    }
}
