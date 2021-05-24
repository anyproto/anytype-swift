import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
class MiddlewareConfigurationService: ConfigurationServiceProtocol {
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        return _obtainConfiguration().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
    
    func _obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        if let configuration = MiddlewareConfiguration.shared {
            return Just(configuration)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map {
                MiddlewareConfiguration(
                    homeBlockID: $0.homeBlockID,
                    archiveBlockID: $0.archiveBlockID,
                    profileBlockId: $0.profileBlockID,
                    gatewayURL: $0.gatewayURL
                )
            }
            .map { configuration in
                MiddlewareConfiguration.shared = configuration
                return configuration
            }
            .eraseToAnyPublisher()
    }
    
    func obtainLibraryVersion() -> AnyPublisher<MiddlewareVersion, Error> {
        Anytype_Rpc.Version.Get.Service.invoke()
            .map { MiddlewareVersion(version: $0.details) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
