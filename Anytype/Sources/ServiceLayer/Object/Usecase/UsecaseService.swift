import ProtobufMessages
import Combine

protocol UsecaseServiceProtocol {
    func setObjectImportDefaultUseCase(spaceId: String) async throws
}

final class UsecaseService: UsecaseServiceProtocol {
    
    func setObjectImportDefaultUseCase(spaceId: String) async throws {
        try await ClientCommands.objectImportUseCase(.with {
            $0.useCase = .getStarted
            $0.spaceID = spaceId
        }).invoke()
    }
    
}
