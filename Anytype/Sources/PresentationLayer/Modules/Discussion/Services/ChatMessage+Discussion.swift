import Services
import Foundation
import ProtobufMessages

extension ChatMessage {

    func resolvedDiscussionBlocks(
        spaceId: String,
        position: MessageHorizontalPosition,
        textBuilder: any DiscussionTextBuilderProtocol
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
                case .paragraph, .description_, .title,
                     .header1, .header2, .header3, .header4:
                    result.append(.text(id: index, content: content))
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

            case .link:
                result.append(.unsupported(id: index, blockName: "link"))
            case .embed:
                result.append(.unsupported(id: index, blockName: "embed"))
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
