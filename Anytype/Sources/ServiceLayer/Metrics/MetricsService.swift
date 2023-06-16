import ProtobufMessages
import Combine
import AnytypeCore

protocol MetricsServiceProtocol {
    func metricsSetParameters() async throws
}

final class MetricsService: MetricsServiceProtocol {
    
    func metricsSetParameters() async throws {
        let appVersion = MetadataProvider.appVersion ?? ""
        let buildNumber = MetadataProvider.buildNumber ?? ""
        let buildIdentifier = MetadataProvider.buildIdentifier ?? ""
        let env = buildIdentifier.contains("dev") ? "-dev" : ""
        try await ClientCommands.metricsSetParameters(.with {
            $0.platform = "iOS"
            $0.version = "\(appVersion)(\(buildNumber))\(env)"
        }).invoke()
    }
    
}
