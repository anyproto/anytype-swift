import ProtobufMessages
import Foundation

public typealias ChatMessage = Anytype_Model_ChatMessage
public typealias ChatMessageAttachment = Anytype_Model_ChatMessage.Attachment
public typealias ChatMessageAttachmentType = Anytype_Model_ChatMessage.Attachment.Type
public typealias ChatMessageContent = Anytype_Model_ChatMessage.MessageContent
public typealias ChatState = Anytype_Model_ChatState
public typealias ChatMessagesReadType = Anytype_Rpc.Chat.ReadMessages.ReadType
public typealias ChatUnreadReadType = Anytype_Rpc.Chat.Unread.ReadType
public typealias ChatUpdateState = Anytype_Event.Chat.UpdateState
public typealias ChatAddData = Anytype_Event.Chat.Add
public typealias ChatDeleteData = Anytype_Event.Chat.Delete

public extension ChatMessage {
    var createdAtDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt))
    }

    var modifiedAtDate: Date? {
        guard modifiedAt != 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(modifiedAt))
    }

    /// Temporary solution to render discussions
    func resolvedContent(useBlocksFormat: Bool) -> ChatMessageContent {
        guard useBlocksFormat, !blocks.isEmpty else { return message }

        var content = ChatMessageContent()
        var combinedText = ""
        var combinedMarks: [Anytype_Model_Block.Content.Text.Mark] = []

        for block in blocks {
            if !combinedText.isEmpty {
                combinedText += "\n"
            }
            let textOffset = Int32(combinedText.utf16.count)

            if case .text(let textBlock) = block.content, textBlock.style == .paragraph {
                combinedText += textBlock.text
                for var mark in textBlock.marks {
                    mark.range.from += textOffset
                    mark.range.to += textOffset
                    combinedMarks.append(mark)
                }
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
        return content
    }
}
