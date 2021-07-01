import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
class MiddlewareConfigurationService: ConfigurationServiceProtocol {
    private var subscriptions = [AnyCancellable]()
    
    func obtainConfiguration(completion: @escaping (MiddlewareConfiguration) -> ()) {
        if let configuration = MiddlewareConfiguration.shared {
            completion(configuration)
        }

        Anytype_Rpc.Config.Get.Service.invoke()
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
            .store(in: &self.subscriptions)
    }
    
    func obtainLibraryVersion() -> AnyPublisher<MiddlewareVersion, Error> {
        Anytype_Rpc.Version.Get.Service.invoke()
            .map { MiddlewareVersion(version: $0.details) }
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
