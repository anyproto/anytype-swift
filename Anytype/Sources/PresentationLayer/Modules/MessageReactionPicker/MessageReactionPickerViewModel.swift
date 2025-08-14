import Foundation
import Services

struct MessageReactionPickerData: Identifiable, Hashable {
    let chatObjectId: String
    let messageId: String
    
    var id: Int { hashValue }
}

@MainActor
final class MessageReactionPickerViewModel: ObservableObject {
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private let data: MessageReactionPickerData
    
    @Published var dismiss = false
    
    init(data: MessageReactionPickerData) {
        self.data = data
    }
    
    func onTapEmoji(_ emoji: EmojiData) {
        Task {
            let added = try await chatService.toggleMessageReaction(chatObjectId: data.chatObjectId, messageId: data.messageId, emoji: emoji.emoji)
            AnytypeAnalytics.instance().logToggleReaction(added: added)
            dismiss.toggle()
        }
    }
}
