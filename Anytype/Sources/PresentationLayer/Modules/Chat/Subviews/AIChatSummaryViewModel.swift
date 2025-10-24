import Foundation
import Services
import SwiftUI
import AnytypeCore

@MainActor
final class AIChatSummaryViewModel: ObservableObject {

    let spaceId: String
    let chatId: String

    @Published var messages: [FullChatMessage] = []
    @Published var isLoading = false

    private let chatStorage: any ChatMessagesStorageProtocol
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol

    init(spaceId: String, chatId: String) {
        self.spaceId = spaceId
        self.chatId = chatId
        self.chatStorage = Container.shared.chatMessageStorage((spaceId, chatId))
    }

    func loadMessages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await chatStorage.startSubscriptionIfNeeded()

            guard let allMessages = await chatStorage.fullMessages else {
                return
            }

            messages = filterLastTwoDays(allMessages)
        } catch {
            anytypeAssertionFailure("Failed to load chat messages", info: ["error": error.localizedDescription])
        }
    }

    private func filterLastTwoDays(_ messages: [FullChatMessage]) -> [FullChatMessage] {
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        return messages.filter { $0.message.createdAtDate >= twoDaysAgo }
    }
}
