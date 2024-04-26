import ProtobufMessages

public protocol MiddlewareConfigurationServiceProtocol {
    func libraryVersion() async throws -> String
}

public final class MiddlewareConfigurationService: MiddlewareConfigurationServiceProtocol {
    
    public init() {}
    
    public func libraryVersion() async throws -> String {
        return try await ClientCommands.appGetVersion().invoke().version
    }
}
