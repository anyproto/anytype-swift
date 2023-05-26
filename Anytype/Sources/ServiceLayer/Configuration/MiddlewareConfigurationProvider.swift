import Foundation
import Combine
import ProtobufMessages
import AnytypeCore

protocol MiddlewareConfigurationProviderProtocol: AnyObject {
    var configuration: MiddlewareConfiguration { get }
    func removeCachedConfiguration()
    func setupConfiguration(account: AccountData)
    // Delete with redesignAbout toggle
    func libraryVersion() -> String?
    func libraryVersion() async throws -> String
}

/// Service that handles middleware config
final class MiddlewareConfigurationProvider {
    
    // MARK: - Private variables
    private var cachedConfiguration: MiddlewareConfiguration?
}

extension MiddlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol {
    
    var configuration: MiddlewareConfiguration {
        if let configuration = cachedConfiguration {
            return configuration
        }
        
        anytypeAssertionFailure("Middleware configurations is empty", domain: .middlewareConfigurationProvider)
        
        return MiddlewareConfiguration.empty
    }
    
    func removeCachedConfiguration() {
        cachedConfiguration = nil
    }
    
    func setupConfiguration(account: AccountData) {
        cachedConfiguration = MiddlewareConfiguration(info: account.info)
    }
    
    func libraryVersion() -> String? {
        return try? ClientCommands.appGetVersion().invoke().version
    }
    
    func libraryVersion() async throws -> String {
        return try await ClientCommands.appGetVersion().invoke(errorDomain: .middlewareConfigurationProvider).version
    }
}
