import Foundation
import FoundationModels
import Services

@available(iOS 26.0, *)
@Generable(description: "Summary of chat conversation with key points and topics")
struct ChatSummary: Sendable {
    @Guide(description: "1-2 most important decisions, actions, or insights")
    let keyPoints: [SummaryPoint]

    @Guide(description: "1-3 main subjects discussed")
    let topics: [SummaryPoint]
}

@available(iOS 26.0, *)
@Generable(description: "A single point in the summary with required message reference")
struct SummaryPoint: Sendable, Identifiable {
    var id: String { text }

    @Guide(description: "Concise description (5-15 words)")
    let text: String

    @Guide(description: "REQUIRED: The message ID most relevant to this point. Must always be provided, never null. Pick the single most relevant message ID from the [messageId] prefixes.")
    let relatedMessageId: String?
}

enum AISummaryError: Error, LocalizedError {
    case notAvailable
    case generationFailed(any Error)
    case exceededContextWindow(String)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "AI summarization requires iOS 26.0 or later with Apple Silicon"
        case .generationFailed(let underlyingError):
            return "Failed to generate summary: \(underlyingError.localizedDescription)"
        case .exceededContextWindow(let context):
            return "Content too large for AI processing. Try with fewer messages.\nContext: \(context)"
        }
    }
}

@available(iOS 26.0, *)
struct ChatSummaryResult: Sendable {
    let summary: ChatSummary
    let messagesAnalyzed: Int
}

@available(iOS 26.0, *)
protocol AISummaryServiceProtocol: Sendable {
    func checkAvailability() -> Bool
    func summarizeMessages(_ messages: [FullChatMessage]) async throws -> ChatSummaryResult
}

@available(iOS 26.0, *)
final class AISummaryService: AISummaryServiceProtocol {

    private let maxTokenLimit = 4000
    private let estimatedCharsPerToken = 3.0
    private let promptOverheadTokens = 350

    func checkAvailability() -> Bool {
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return true
            case .unavailable:
                return false
            @unknown default:
                return false
            }
        }
        return false
    }

    func summarizeMessages(_ messages: [FullChatMessage]) async throws -> ChatSummaryResult {
        guard #available(iOS 26.0, *) else {
            throw AISummaryError.notAvailable
        }

        guard checkAvailability() else {
            throw AISummaryError.notAvailable
        }

        do {
            return try await attemptSummarize(messages, trimRatio: 1.0)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return try await attemptSummarize(messages, trimRatio: 0.10)
        }
    }

    private func attemptSummarize(_ messages: [FullChatMessage], trimRatio: Double) async throws -> ChatSummaryResult {
        guard #available(iOS 26.0, *) else {
            throw AISummaryError.notAvailable
        }

        let session = LanguageModelSession()

        let totalCount = messages.count
        var trimmedMessages = trimMessagesToFitLimit(messages)

        if trimRatio < 1.0 {
            let targetCount = max(1, Int(Double(trimmedMessages.count) * trimRatio))
            trimmedMessages = Array(trimmedMessages.suffix(targetCount))
        }

        let wasTrimmed = trimmedMessages.count < totalCount
        let messagesAnalyzed = trimmedMessages.count

        let messageTexts = trimmedMessages.enumerated().map { index, msg in
            """
            M: \(msg.message.id)
            F: \(msg.message.creator)
            T: \(msg.message.message.text)
            ---
            """
        }.joined(separator: "\n")

        let conversationContext = wasTrimmed
            ? "chat conversation (showing last \(trimmedMessages.count) of \(totalCount) messages)"
            : "chat conversation"

        let prompt = """
        MESSAGE FORMAT: Each message has three fields:
        M: message_id (USE THIS for relatedMessageId)
        F: user_name (DO NOT use this)
        T: message text
        ---

        Example:
        M: abc123
        F: John
        T: Let's move to the new database
        ---

        CRITICAL: For relatedMessageId, extract ONLY the value after "M:" - never use the "F:" value.

        Analyze this \(conversationContext):

        \(messageTexts)

        Identify key decisions/actions (keyPoints) and main subjects (topics). For each point, you MUST provide the relatedMessageId by extracting the value after "M:" from the most relevant message.

        Rules:
        - REQUIRED: relatedMessageId must be the value after "M:", never the "F:" value, never null
        - Start text with action verbs or nouns (not "The", "Users", "Discussion")
        - Be specific: names, numbers, features mentioned
        - Skip generic phrases like "discussed", "focused on"
        - Total: max 50 words across all items
        - Prioritize: decisions > action items > specific problems > general topics
        """

        do {
            let response = try await session.respond(
                to: prompt,
                generating: ChatSummary.self
            )
            return ChatSummaryResult(summary: response.content, messagesAnalyzed: messagesAnalyzed)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            throw AISummaryError.exceededContextWindow("Token limit exceeded even after trimming. Context: \(context)")
        } catch {
            throw AISummaryError.generationFailed(error)
        }
    }

    private func trimMessagesToFitLimit(_ messages: [FullChatMessage]) -> [FullChatMessage] {
        let availableTokens = maxTokenLimit - promptOverheadTokens
        let maxChars = (availableTokens * estimatedCharsPerToken) * 0.8

        var trimmedMessages: [FullChatMessage] = []
        var currentLength: Double = 0

        for message in messages.reversed() {
            let messageText = """
            M: \(message.message.id)
            F: \(message.message.creator)
            T: \(message.message.message.text)
            ---
            """
            let messageLength = messageText.count

            if currentLength + Double(messageLength) <= maxChars {
                trimmedMessages.insert(message, at: 0)
                currentLength += Double(messageLength) + 1
            } else {
                break
            }
        }

        if trimmedMessages.isEmpty, let lastMessage = messages.last {
            return [lastMessage]
        }

        return trimmedMessages
    }
}
