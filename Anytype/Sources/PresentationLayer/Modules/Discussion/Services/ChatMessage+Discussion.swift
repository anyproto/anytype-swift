import Services
import Foundation
import ProtobufMessages

extension ChatMessage {

    /// Discussion-specific resolved content that preserves block style information for header rendering
    func resolvedDiscussionContent() -> ResolvedDiscussionContent {
        guard !blocks.isEmpty else {
            return ResolvedDiscussionContent(content: message, blockStyleRanges: [])
        }

        let supportedTextStyles: Set<Anytype_Model_Block.Content.Text.Style> = [
            .paragraph, .description_, .title,
            .header1, .header2, .header3, .header4,
            .toggle, .numbered, .marked, .checkbox, .quote, .callout
        ]

        var content = ChatMessageContent()
        var combinedText = ""
        var combinedMarks: [Anytype_Model_Block.Content.Text.Mark] = []
        var blockStyleRanges: [ResolvedDiscussionContent.BlockStyleRange] = []

        for block in blocks {
            if !combinedText.isEmpty {
                combinedText += "\n"
            }
            let textOffset = Int32(combinedText.utf16.count)

            if case .text(let textBlock) = block.content, supportedTextStyles.contains(textBlock.style) {
                combinedText += textBlock.text
                for var mark in textBlock.marks {
                    mark.range.from += textOffset
                    mark.range.to += textOffset
                    combinedMarks.append(mark)
                }
                let range = NSRange(location: Int(textOffset), length: textBlock.text.utf16.count)
                blockStyleRanges.append(ResolvedDiscussionContent.BlockStyleRange(style: textBlock.style, range: range))
            } else if case .text(let textBlock) = block.content {
                let placeholder = "UNSUPPORTED STYLE (\(textBlock.style)): \(textBlock.text)"
                combinedText += placeholder
                var mark = Anytype_Model_Block.Content.Text.Mark()
                mark.type = .textColor
                mark.param = MiddlewareColor.red.rawValue
                mark.range = Anytype_Model_Range()
                mark.range.from = textOffset
                mark.range.to = textOffset + Int32(placeholder.utf16.count)
                combinedMarks.append(mark)
            } else {
                let blockName: String
                switch block.content {
                case .link: blockName = "link"
                case .embed: blockName = "embed"
                case .text, nil: blockName = "unknown"
                }
                let placeholder = "UNSUPPORTED BLOCK: \(blockName)"
                combinedText += placeholder
                var mark = Anytype_Model_Block.Content.Text.Mark()
                mark.type = .textColor
                mark.param = MiddlewareColor.red.rawValue
                mark.range = Anytype_Model_Range()
                mark.range.from = textOffset
                mark.range.to = textOffset + Int32(placeholder.utf16.count)
                combinedMarks.append(mark)
            }
        }

        content.text = combinedText
        content.marks = combinedMarks
        return ResolvedDiscussionContent(content: content, blockStyleRanges: blockStyleRanges)
    }
}
