import Foundation
import Combine

protocol ConfigurationServiceProtocol {
    func obtainConfiguration(completion: @escaping (MiddlewareConfiguration) -> ())
    
    func obtainLibraryVersion() -> AnyPublisher<MiddlewareVersion, Error>
}
