import Foundation
import ProtobufMessages

public protocol AIServiceProtocol: AnyObject, Sendable {
    func aiListSummary(spaceId: String, objectIds: [String], prompt: String, config: AIProviderConfig) async throws -> String
}

final class AIService: AIServiceProtocol {
    func aiListSummary(spaceId: String, objectIds: [String], prompt: String, config: AIProviderConfig) async throws -> String {
        let result = try await ClientCommands.aIListSummary(.with {
            $0.spaceID = spaceId
            $0.objectIds = objectIds
            $0.prompt = prompt
            $0.config = config
        }).invoke()
        return result.objectID
    }
}
