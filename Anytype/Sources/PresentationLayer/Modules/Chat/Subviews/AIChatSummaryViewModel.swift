import Foundation
import Services
import SwiftUI
import AnytypeCore

@available(iOS 26.0, *)
@MainActor
final class AIChatSummaryViewModel: ObservableObject {

    let spaceId: String
    let chatId: String

    @Published var messages: [FullChatMessage] = []
    @Published var isLoading = false
    @Published var summary: ChatSummary?
    @Published var isSummarizing = false
    @Published var summaryError: String?
    @Published var selectedMessage: FullChatMessage?
    @Published var messagesAnalyzed: Int?

    private let chatStorage: any ChatMessagesStorageProtocol
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol
//    @Injected(\.aiSummaryService)
    private let aiSummaryService: some AISummaryServiceProtocol = AISummaryService()

    var isAIAvailable: Bool {
        aiSummaryService.checkAvailability()
    }

    var canGenerateSummary: Bool {
        !messages.isEmpty && isAIAvailable && summary == nil && !isSummarizing
    }

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

    func generateSummary() async {
        guard canGenerateSummary else { return }

        isSummarizing = true
        summaryError = nil
        defer { isSummarizing = false }

        do {
            let result = try await aiSummaryService.summarizeMessages(messages)
            summary = result.summary
            messagesAnalyzed = result.messagesAnalyzed
        } catch let error as AISummaryError {
            summaryError = error.errorDescription
        } catch {
            summaryError = "Failed to generate summary: \(error.localizedDescription)"
        }
    }

    func findMessage(byId id: String) -> FullChatMessage? {
        let trimmedId = id.trimmingCharacters(in: .whitespacesAndNewlines)
        return messages.first {
            $0.message.id.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedId
        }
    }

    private func filterLastTwoDays(_ messages: [FullChatMessage]) -> [FullChatMessage] {
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        return messages.filter { $0.message.createdAtDate >= twoDaysAgo }
    }
}
