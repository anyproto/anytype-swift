import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
class MiddlewareConfigurationService: ConfigurationServiceProtocol {
    private let storage = InMemoryStoreFacade.shared.middlewareConfigurationStore

    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        let configuration = self.storage?.get(by: MiddlewareConfiguration.self)

        if let configuration = configuration {
            return Just(configuration)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .map {
                MiddlewareConfiguration(
                    homeBlockID: $0.homeBlockID,
                    archiveBlockID: $0.archiveBlockID,
                    profileBlockId: $0.profileBlockID,
                    gatewayURL: $0.gatewayURL
                )
            }
            .map { [weak self] configuration in
                self?.storage?.add(configuration)
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
    
    // TODO: Rethink result type.
    // Maybe we would like to return Result?
    private func save(configuration: MiddlewareConfiguration) {
        self.storage?.add(configuration)
    }
}
