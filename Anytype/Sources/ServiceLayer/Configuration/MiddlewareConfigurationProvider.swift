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
        
        let result = Anytype_Rpc.Config.Get.Service.invoke()
        switch result {
        case .success(let response):
            let config = MiddlewareConfiguration(response: response)
            cachedConfiguration = config
            return config
            
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: .middlewareConfigurationProvider)
            
            // Error will be returned if we try to get MiddlewareConfiguration without authorization
            return MiddlewareConfiguration.empty
        }
    }
    
    func removeCacheConfiguration() {
        cachedConfiguration = nil
    }
    
    func libraryVersion() -> String? {
        return try? Anytype_Rpc.Version.Get.Service.invoke().get().version
    }
    
}
