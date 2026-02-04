import Foundation
import Services

struct MessageReactionPickerData: Identifiable, Hashable {
    let chatObjectId: String
    let messageId: String
    
    var id: Int { hashValue }
}

@MainActor
@Observable
final class MessageReactionPickerViewModel {

    @ObservationIgnored
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol

    private let data: MessageReactionPickerData

    var dismiss = false
    
    init(data: MessageReactionPickerData) {
        self.data = data
    }
    
    func onTapEmoji(_ emoji: EmojiData) {
        Task {
            let added = try await chatService.toggleMessageReaction(chatObjectId: data.chatObjectId, messageId: data.messageId, emoji: emoji.emoji)
            AnytypeAnalytics.instance().logToggleReaction(added: added, chatId: data.chatObjectId)
            dismiss.toggle()
        }
    }
}
