import ProtobufMessages
import Combine

protocol UsecaseServiceProtocol: Sendable {
    func setObjectImportDefaultUseCase(spaceId: String) async throws -> String
}

final class UsecaseService: UsecaseServiceProtocol, Sendable {
    
    func setObjectImportDefaultUseCase(spaceId: String) async throws  -> String {
        let result = try await ClientCommands.objectImportUseCase(.with {
            $0.useCase = .getStartedMobile
            $0.spaceID = spaceId
        }).invoke()
        return result.startingObjectID
    }
    
}
