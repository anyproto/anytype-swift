import Foundation
import AnytypeCore
import Logger
#if canImport(FoundationModels)
import FoundationModels
#endif

protocol QuickCaptureTypeSuggestionServiceProtocol: AnyObject, Sendable {
    var isAvailable: Bool { get }
    func prewarm()
    func suggestType(text: String, typeNames: [String]) async -> String?
}

// Classifies captured text against the space's type names using the on-device
// Apple Foundation Models. Constrained decoding (anyOf schema) makes an
// out-of-list answer structurally impossible. Every failure - model unavailable,
// guardrail refusal, unsupported language - degrades to "no suggestion".
final class QuickCaptureTypeSuggestionService: QuickCaptureTypeSuggestionServiceProtocol, Sendable {

    private enum Constants {
        static let minTextLength = 3
        static let maxTextLength = 500
        static let instructions = """
        You classify a user's note into one of the given object types. \
        Pick the single type name that best fits the note's content.
        """
    }

    private static let log = EventLogger(category: "QuickCaptureTypeSuggestion")

    var isAvailable: Bool {
        guard FeatureFlags.quickCaptureTypeSuggestions else { return false }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return true
            case .unavailable(let reason):
                Self.log.debug("Model unavailable", metadata: ["reason": "\(reason)"])
                return false
            @unknown default:
                return false
            }
        }
        #endif
        return false
    }

    // Loading model resources takes ~1-2s cold - warm them up while the user types
    func prewarm() {
        guard isAvailable else { return }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            Task.detached(priority: .userInitiated) {
                LanguageModelSession(instructions: Constants.instructions).prewarm()
            }
        }
        #endif
    }

    func suggestType(text: String, typeNames: [String]) async -> String? {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isAvailable, text.count >= Constants.minTextLength, typeNames.isNotEmpty else { return nil }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            do {
                let typeSchema = DynamicGenerationSchema(
                    name: "ObjectType",
                    description: "The object type that best fits the note",
                    anyOf: typeNames
                )
                let schema = try GenerationSchema(root: typeSchema, dependencies: [])
                // A fresh session per request keeps the transcript out of the
                // 4096-token context window; the model itself stays warm
                let session = LanguageModelSession(instructions: Constants.instructions)
                let response = try await session.respond(
                    to: Prompt(String(text.prefix(Constants.maxTextLength))),
                    schema: schema
                )
                let name = try response.content.value(String.self)
                Self.log.debug("Suggestion", metadata: ["type": name, "known": "\(typeNames.contains(name))"])
                return typeNames.contains(name) ? name : nil
            } catch {
                Self.log.debug("Suggestion failed", metadata: ["error": "\(error)"])
                return nil
            }
        }
        #endif
        return nil
    }
}
