import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
class MiddlewareConfigurationService: ConfigurationServiceProtocol {
    private let storage = MiddlewareConfigurationStore.shared

    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        if let configuration = storage.get(by: MiddlewareConfiguration.self) {
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
            .map { [weak self] configuration in
                self?.storage.add(configuration)
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
    
    private func save(configuration: MiddlewareConfiguration) {
        storage.add(configuration)
    }
}
