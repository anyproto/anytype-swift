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
        
        return MiddlewareConfiguration.empty
    }
    
    func removeCachedConfiguration() {
        cachedConfiguration = nil
    }
    
    func setupConfiguration(account: AccountData) {
        cachedConfiguration = MiddlewareConfiguration(info: account.info)
    }
    
    func libraryVersion() -> String? {
        return try? Anytype_Rpc.App.GetVersion.Service.invoke().get().version
    }
    
}
