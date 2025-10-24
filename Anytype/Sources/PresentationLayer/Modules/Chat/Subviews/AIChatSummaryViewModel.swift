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
    @Published var summary: String = ""
    @Published var isSummarizing = false
    @Published var summaryError: String?

    private let chatStorage: any ChatMessagesStorageProtocol
    @Injected(\.messageTextBuilder)
    private var messageTextBuilder: any MessageTextBuilderProtocol
    @Injected(\.aiSummaryService)
    private var aiSummaryService: any AISummaryServiceProtocol

    var isAIAvailable: Bool {
        aiSummaryService.checkAvailability()
    }

    var canGenerateSummary: Bool {
        !messages.isEmpty && isAIAvailable && summary.isEmpty && !isSummarizing
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
            summary = try await aiSummaryService.summarizeMessages(messages)
        } catch let error as AISummaryError {
            summaryError = error.errorDescription
        } catch {
            summaryError = "Failed to generate summary: \(error.localizedDescription)"
        }
    }

    private func filterLastTwoDays(_ messages: [FullChatMessage]) -> [FullChatMessage] {
        let twoDaysAgo = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        return messages.filter { $0.message.createdAtDate >= twoDaysAgo }
    }
}
