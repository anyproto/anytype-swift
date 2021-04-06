import Foundation
import Combine

fileprivate typealias Namespace = CoreLayer.Network.Image

// MARK: - URLResolver
extension Namespace {
    struct URLResolver {
        
        private enum Constants {
            static let imageSubPath = "/image/"
            static let fileSubPath = "/file/"
        }
        
        private let configurationService = MiddlewareConfigurationService.init()
        
        private func imageURL(configuration: MiddlewareConfigurationService.MiddlewareConfiguration, subpath: String, parameters: ImageParameters?) -> URL? {
            guard !subpath.isEmpty else { return nil }
            
            let string = configuration.gatewayURL + Constants.imageSubPath + subpath
            
            /// Get components.
            var components = URLComponents(string: string)
            if let parameters = parameters {
                components?.queryItems = try? URLComponentsEncoder().encode(parameters)
            }
            
            return components?.url
        }
        
        private func fileURL(configuration: MiddlewareConfigurationService.MiddlewareConfiguration, fileId: String) -> URL? {
            URL(string: configuration.gatewayURL + Constants.fileSubPath + fileId)
        }
        
        /// Request url for file with hash
        ///
        /// - Parameters:
        ///   - fileId: file hash
        func transform(fileId: String) -> AnyPublisher<URL?, Error> {
            self.configurationService.obtainConfiguration().map { self.fileURL(configuration: $0,
                                                                               fileId: fileId) }.eraseToAnyPublisher()
        }

        func transform(imageId: String, _ parameters: ImageParameters? = nil) -> AnyPublisher<URL?, Error> {
            self.configurationService.obtainConfiguration().map({self.imageURL(configuration: $0, subpath: imageId, parameters: parameters)}).eraseToAnyPublisher()
        }
    }
}
