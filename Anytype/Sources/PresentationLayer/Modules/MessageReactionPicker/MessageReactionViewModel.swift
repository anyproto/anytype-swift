import Foundation

final class MessageReactionViewModel: ObservableObject {
    
    private let messageId: String
    
    init(messageId: String) {
        self.messageId = messageId
    }
    
    func onTapEmoji(_ emoji: EmojiData) {
        // TODO: Handle
    }
}
