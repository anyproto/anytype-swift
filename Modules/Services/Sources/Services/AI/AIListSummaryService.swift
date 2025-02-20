import Foundation
import ProtobufMessages

public protocol AIListSummaryServiceProtocol: AnyObject, Sendable {
    func aiListSummary(spaceId: String, objectIds: [String], prompt: String, config: AIProviderConfig) async throws -> String
}

final class AIListSummaryService: AIListSummaryServiceProtocol {
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
