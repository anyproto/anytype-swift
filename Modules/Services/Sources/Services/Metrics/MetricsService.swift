import ProtobufMessages
import Combine

public protocol MetricsServiceProtocol: Sendable {
    func setInitialParameters(platform: String, version: String) async throws
}

final class MetricsService: MetricsServiceProtocol {
    
    public func setInitialParameters(platform: String, version: String) async throws {
        try await ClientCommands.initialSetParameters(.with {
            $0.platform = platform
            $0.version = version
        }).invoke()
    }
    
}
