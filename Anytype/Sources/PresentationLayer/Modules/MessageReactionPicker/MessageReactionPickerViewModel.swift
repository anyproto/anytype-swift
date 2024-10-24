import Foundation

final class MessageReactionPickerViewModel: ObservableObject {
    
    private let messageId: String
    
    @Published var dismiss = false
    
    init(messageId: String) {
        self.messageId = messageId
    }
    
    func onTapEmoji(_ emoji: EmojiData) {
        // TODO: Handle
        dismiss.toggle()
    }
}
