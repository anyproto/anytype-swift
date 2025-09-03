import Foundation
import Combine
import UIKit
import Services

@MainActor
final class ChatDeleteMessageAlertModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.chatService)
    private var chatService: any ChatServiceProtocol
    
    private let data: ChatDeleteMessageAlertData
    
    init(data: ChatDeleteMessageAlertData) {
        self.data = data
    }
    
    func onTapDelete() async throws {
        AnytypeAnalytics.instance().logDeleteMessage()
        try await chatService.deleteMessage(chatObjectId: data.chatId, messageId: data.messageId)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
