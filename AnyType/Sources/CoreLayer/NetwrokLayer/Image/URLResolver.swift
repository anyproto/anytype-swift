
import Foundation
import Combine

/// Entity to convert file hashes from middle to URLs
struct URLResolver {
    
    private enum Constants {
        static let imageSubPath = "/image/"
        static let fileSubPath = "/file/"
    }
    
    private let configurationService = MiddlewareConfigurationService.init()
    
    private func imageURL(configuration: MiddlewareConfiguration,
                          subpath: String,
                          parameters: CoreLayer.Network.Image.ImageParameters?) -> URL? {
        guard !subpath.isEmpty else { return nil }
        
        let string = configuration.gatewayURL + Constants.imageSubPath + subpath
        
        /// Get components.
        var components = URLComponents(string: string)
        if let parameters = parameters {
            components?.queryItems = try? URLComponentsEncoder().encode(parameters)
        }
        
        return components?.url
    }
    
    private func fileURL(configuration: MiddlewareConfiguration, fileId: String) -> URL? {
        URL(string: configuration.gatewayURL + Constants.fileSubPath + fileId)
    }
    
    /// Obtain url for file with hash
    ///
    /// - Parameters:
    ///   - fileId: file hash
    func obtainFileURLPublisher(fileId: String) -> AnyPublisher<URL?, Error> {
        self.configurationService.obtainConfiguration().map {
            self.fileURL(configuration: $0, fileId: fileId)
        }
        .eraseToAnyPublisher()
    }
    
    /// Obtain url for image with hash
    ///
    /// - Parameters:
    ///   - imageId: image hash
    ///   - parameters: Image parameters
    func obtainImageURLPublisher(imageId: String,
                   _ parameters: CoreLayer.Network.Image.ImageParameters? = nil) -> AnyPublisher<URL?, Error> {
        self.configurationService.obtainConfiguration().map({self.imageURL(configuration: $0,
                                                                           subpath: imageId,
                                                                           parameters: parameters)}).eraseToAnyPublisher()
    }
}
