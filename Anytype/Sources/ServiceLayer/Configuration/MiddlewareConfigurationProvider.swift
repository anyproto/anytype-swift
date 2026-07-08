import Foundation
import Combine
import AnytypeCore
import Services

protocol MiddlewareConfigurationProviderProtocol: AnyObject, Sendable {
    var configuration: MiddlewareConfiguration { get }
    func removeCachedConfiguration()
    func setupConfiguration(account: AccountData)
    func libraryVersion() async throws -> String
}

/// Service that handles middleware config
final class MiddlewareConfigurationProvider: MiddlewareConfigurationProviderProtocol {
    
    // MARK: - Private variables
    private let storage = AtomicStorage<MiddlewareConfiguration?>(nil)
    // libraryVersion is constant for the process lifetime — cache it to avoid
    // repeat middleware RPCs (About screen composes diagnostic info several times).
    private let libraryVersionStorage = AtomicStorage<String?>(nil)
    private let middlewareConfigurationService: any MiddlewareConfigurationServiceProtocol = Container.shared.middlewareConfigurationService()

    var configuration: MiddlewareConfiguration {
        if let configuration = storage.value {
            return configuration
        }
        
        anytypeAssertionFailure("Middleware configurations is empty")
        
        return MiddlewareConfiguration.empty
    }
    
    func removeCachedConfiguration() {
        storage.value = nil
    }
    
    func setupConfiguration(account: AccountData) {
        storage.value = MiddlewareConfiguration(info: account.info)
    }
    
    func libraryVersion() async throws -> String {
        if let cached = libraryVersionStorage.value {
            return cached
        }
        let version = try await middlewareConfigurationService.libraryVersion()
        libraryVersionStorage.value = version
        return version
    }
}
