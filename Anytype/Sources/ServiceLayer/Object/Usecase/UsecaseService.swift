import ProtobufMessages
import Combine

protocol UsecaseServiceProtocol {
    func setObjectImportUseCaseToSkip(spaceId: String) async throws
}

final class UsecaseService: UsecaseServiceProtocol {
    
    func setObjectImportUseCaseToSkip(spaceId: String) async throws {
        try await ClientCommands.objectImportUseCase(.with {
            $0.useCase = .skip
            $0.spaceID = spaceId
        }).invoke()
    }
    
}
