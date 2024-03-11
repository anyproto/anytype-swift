import Foundation
import Combine
import AnytypeCore
import Services

protocol MiddlewareConfigurationProviderProtocol: AnyObject {
    var configuration: MiddlewareConfiguration { get }
    func removeCachedConfiguration()
    func setupConfiguration(account: AccountData)
    func libraryVersion() async throws -> String
}

/// Service that handles middleware config
final class MiddlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol {
    
    // MARK: - Private variables
    private var cachedConfiguration: MiddlewareConfiguration?
    @Injected(\.middlewareConfigurationService)
    private var middlewareConfigurationService: MiddlewareConfigurationServiceProtocol

    var configuration: MiddlewareConfiguration {
        if let configuration = cachedConfiguration {
            return configuration
        }
        
        anytypeAssertionFailure("Middleware configurations is empty")
        
        return MiddlewareConfiguration.empty
    }
    
    func removeCachedConfiguration() {
        cachedConfiguration = nil
    }
    
    func setupConfiguration(account: AccountData) {
        cachedConfiguration = MiddlewareConfiguration(info: account.info)
    }
    
    func libraryVersion() async throws -> String {
        return try await middlewareConfigurationService.libraryVersion()
    }
}
