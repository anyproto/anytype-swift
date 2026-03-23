import ProtobufMessages
import Foundation

public struct ResolvedDiscussionContent {
    public var content: ChatMessageContent
    public var blockStyleRanges: [BlockStyleRange]

    public struct BlockStyleRange {
        public var style: Anytype_Model_Block.Content.Text.Style
        public var range: NSRange // UTF-16 range in combined text

        public init(style: Anytype_Model_Block.Content.Text.Style, range: NSRange) {
            self.style = style
            self.range = range
        }
    }

    public init(content: ChatMessageContent, blockStyleRanges: [BlockStyleRange]) {
        self.content = content
        self.blockStyleRanges = blockStyleRanges
    }
}
