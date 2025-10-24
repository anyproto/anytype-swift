import Foundation
import FoundationModels
import Services

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

protocol AISummaryServiceProtocol: Sendable {
    func checkAvailability() -> Bool
    func summarizeMessages(_ messages: [FullChatMessage]) async throws -> String
}

final class AISummaryService: AISummaryServiceProtocol {

    private let maxTokenLimit = 4096
    private let estimatedCharsPerToken = 3.0
    private let promptOverheadTokens = 300

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

    func summarizeMessages(_ messages: [FullChatMessage]) async throws -> String {
        guard #available(iOS 26.0, *) else {
            throw AISummaryError.notAvailable
        }

        guard checkAvailability() else {
            throw AISummaryError.notAvailable
        }

        do {
            return try await attemptSummarize(messages, trimRatio: 1.0)
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize {
            return try await attemptSummarize(messages, trimRatio: 0.3)
        }
    }

    private func attemptSummarize(_ messages: [FullChatMessage], trimRatio: Double) async throws -> String {
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

        let messageTexts = trimmedMessages.map { msg in
            "\(msg.message.creator): \(msg.message.message.text)"
        }.joined(separator: "\n")

        let conversationContext = wasTrimmed
            ? "chat conversation (showing last \(trimmedMessages.count) of \(totalCount) messages)"
            : "chat conversation"

        let prompt = """
        You are an expert at summarizing chat conversations. Analyze the following \(conversationContext):

        \(messageTexts)

        Provide a concise summary (2-3 sentences, max 50 words) that captures:
        • Main topics and themes discussed
        • Key points, decisions, or conclusions reached
        • Overall sentiment or tone

        Write clearly and avoid generic phrases. Focus on what's most valuable to know.
        """

        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch LanguageModelSession.GenerationError.exceededContextWindowSize(let context) {
            throw AISummaryError.exceededContextWindow("Token limit exceeded even after trimming. Context: \(context)")
        } catch {
            throw AISummaryError.generationFailed(error)
        }
    }

    private func trimMessagesToFitLimit(_ messages: [FullChatMessage]) -> [FullChatMessage] {
        let availableTokens = maxTokenLimit - promptOverheadTokens
        let maxChars = availableTokens * estimatedCharsPerToken

        var trimmedMessages: [FullChatMessage] = []
        var currentLength: Double = 0

        for message in messages.reversed() {
            let messageText = "\(message.message.creator): \(message.message.message.text)"
            let messageLength = messageText.count

            if currentLength + Double(messageLength) <= maxChars {
                trimmedMessages.insert(message, at: 0)
                currentLength += messageLength + 1
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
