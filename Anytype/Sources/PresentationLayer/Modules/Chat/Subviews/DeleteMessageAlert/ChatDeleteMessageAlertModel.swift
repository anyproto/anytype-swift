import Foundation
import Combine
import UIKit
import Services

@MainActor
final class ChatDeleteMessageAlertModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private let message: MessageViewData
    
    init(message: MessageViewData) {
        self.message = message
    }
    
    func onTapDelete() async throws {
        AnytypeAnalytics.instance().logDeleteMessage()
        try await chatService.deleteMessage(chatObjectId: message.chatId, messageId: message.message.id)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
