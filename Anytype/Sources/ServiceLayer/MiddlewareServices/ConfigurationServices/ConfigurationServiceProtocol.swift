import Foundation
import Combine

/// Service that handles middleware config
protocol ConfigurationServiceProtocol {
    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error>

    
    func obtainLibraryVersion() -> AnyPublisher<MiddlewareVersion, Error>
}
