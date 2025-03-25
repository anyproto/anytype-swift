import Foundation
import ProtobufMessages
import AnytypeCore

public protocol AIServiceProtocol: AnyObject, Sendable {
    func aiListSummary(spaceId: String, objectIds: [String], prompt: String, config: AIProviderConfig) async throws -> String
    func aiObjectCreateFromUrl(spaceId: String, url: AnytypeURL, config: AIProviderConfig) async throws -> ObjectDetails
    
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
    
    func aiObjectCreateFromUrl(spaceId: String, url: AnytypeURL, config: AIProviderConfig) async throws -> ObjectDetails {
        let result = try await ClientCommands.aIObjectCreateFromUrl(.with {
            $0.spaceID = spaceId
            $0.url = url.absoluteString
            $0.config = config
        }).invoke()
        return try result.details.toDetails()
    }
}
