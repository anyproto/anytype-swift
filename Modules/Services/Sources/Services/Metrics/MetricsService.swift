import ProtobufMessages
import Combine

public protocol MetricsServiceProtocol: Sendable {
    func metricsSetParameters(platform: String, version: String) async throws
}

final class MetricsService: MetricsServiceProtocol {
    
    public func metricsSetParameters(platform: String, version: String) async throws {
        try await ClientCommands.metricsSetParameters(.with {
            $0.platform = platform
            $0.version = version
        }).invoke()
    }
    
}
