import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
final class MiddlewareConfigurationService {
    
    // MARK: - Initializer
    static let shared = MiddlewareConfigurationService()
    
    // MARK: - Internal veriables
    private(set) var configuration: MiddlewareConfiguration?
}

extension MiddlewareConfigurationService {
    
    func obtainAndCacheConfiguration() {
        getConfiguration { [weak self] config in
            self?.configuration = config
        }
    }
    
    func removeCacheConfiguration() {
        configuration = nil
    }
    
    func libraryVersionPublisher() -> AnyPublisher<MiddlewareVersion, Error> {
        Anytype_Rpc.Version.Get.Service.invoke()
            .map { MiddlewareVersion(version: $0.details) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func getConfiguration(onCompletion: @escaping (MiddlewareConfiguration) -> Void) {
        let _ = Anytype_Rpc.Config.Get.Service.invoke()
            .map {
                MiddlewareConfiguration(
                    homeBlockID: $0.homeBlockID,
                    archiveBlockID: $0.archiveBlockID,
                    profileBlockId: $0.profileBlockID,
                    gatewayURL: $0.gatewayURL
                )
            }
            .sinkWithDefaultCompletion("ObtainConfiguration") { config in
                onCompletion(config)
            }
    }
    
}

extension MiddlewareConfigurationService {
    
    @available(*, deprecated)
    func obtainConfiguration(completion: @escaping (MiddlewareConfiguration) -> ()) {
        if let configuration = MiddlewareConfiguration.shared {
            completion(configuration)
        }

        let _ = Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .map {
                MiddlewareConfiguration(
                    homeBlockID: $0.homeBlockID,
                    archiveBlockID: $0.archiveBlockID,
                    profileBlockId: $0.profileBlockID,
                    gatewayURL: $0.gatewayURL
                )
            }
            .receiveOnMain()
            .sinkWithDefaultCompletion("ObtainConfiguration") { config in
                MiddlewareConfiguration.shared = config
                completion(config)
            }
    }
    
}
