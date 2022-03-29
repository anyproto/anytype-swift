import Foundation
import Combine
import ProtobufMessages
import AnytypeCore

/// Service that handles middleware config
final class MiddlewareConfigurationProvider {
    
    // MARK: - Initializer
    static let shared = MiddlewareConfigurationProvider()
    
    // MARK: - Private variables
    private var cachedConfiguration: MiddlewareConfiguration?
}

extension MiddlewareConfigurationProvider {
    
    var configuration: MiddlewareConfiguration {
        if let configuration = cachedConfiguration {
            return configuration
        }
        
        let config: MiddlewareConfiguration? = Anytype_Rpc.Config.Get.Service.invoke()
            .map { MiddlewareConfiguration(response: $0) }
            .getValue(domain: .middlewareConfigurationProvider)
        
        guard let config = config else {
            // Error will be returned if we try to get MiddlewareConfiguration without authorization
            return MiddlewareConfiguration.empty
        }
        
        cachedConfiguration = config
        return config
    }
    
    func removeCachedConfiguration() {
        cachedConfiguration = nil
    }
    
    func libraryVersion() -> String? {
        return try? Anytype_Rpc.Version.Get.Service.invoke().get().version
    }
    
}
