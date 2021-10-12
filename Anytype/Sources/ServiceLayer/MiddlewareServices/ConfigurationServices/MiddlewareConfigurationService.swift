import Foundation
import Combine
import ProtobufMessages

/// Service that handles middleware config
final class MiddlewareConfigurationService {
    
    // MARK: - Initializer
    static let shared = MiddlewareConfigurationService()
    
    // MARK: - Private variables
    private var cachedConfiguration: MiddlewareConfiguration?
}

extension MiddlewareConfigurationService {
    
    func configuration() -> MiddlewareConfiguration {
        if let configuration = cachedConfiguration {
            return configuration
        }
        
        guard let result = try? Anytype_Rpc.Config.Get.Service.invoke().get() else {
            // Error will be returned if we try to get MiddlewareConfiguration without authorization
            return MiddlewareConfiguration(
                homeBlockID: "",
                archiveBlockID: "",
                profileBlockId: "",
                gatewayURL: ""
            )
        }
        
        let config = MiddlewareConfiguration(
            homeBlockID: result.homeBlockID,
            archiveBlockID: result.archiveBlockID,
            profileBlockId: result.profileBlockID,
            gatewayURL: result.gatewayURL
        )
        
        cachedConfiguration = config
        
        return config
    }
    
    
    func removeCacheConfiguration() {
        cachedConfiguration = nil
    }
    
    func libraryVersion() -> String? {
        return try? Anytype_Rpc.Version.Get.Service.invoke().get().version
    }
    
}
