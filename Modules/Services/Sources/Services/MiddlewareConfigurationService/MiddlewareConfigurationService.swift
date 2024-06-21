import ProtobufMessages

public protocol MiddlewareConfigurationServiceProtocol: Sendable {
    func libraryVersion() async throws -> String
}

final class MiddlewareConfigurationService: MiddlewareConfigurationServiceProtocol {
    
    public func libraryVersion() async throws -> String {
        return try await ClientCommands.appGetVersion().invoke().version
    }
}
