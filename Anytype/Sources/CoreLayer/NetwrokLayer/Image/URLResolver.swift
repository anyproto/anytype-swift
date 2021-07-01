
import Foundation
import Combine

struct URLResolver {
    private let configurationService = MiddlewareConfigurationService()
    
    func obtainFileURL(fileId: String, completion: @escaping (URL?) -> ()) {
        configurationService.obtainConfiguration { config in
            completion(
                URL(string: config.gatewayURL + Constants.fileSubPath + fileId)
            )
        }
    }
    
    func obtainImageURL(imageId: String, parameters: ImageParameters, completion: @escaping (URL?) -> ()) {
        configurationService.obtainConfiguration { config in
            completion(imageURL(configuration: config, subpath: imageId, parameters: parameters))
        }
    }
    
    private func imageURL(
        configuration: MiddlewareConfiguration,
        subpath: String,
        parameters: ImageParameters
    ) -> URL? {
        guard !subpath.isEmpty else { return nil }
        
        let string = configuration.gatewayURL + Constants.imageSubPath + subpath
        
        var components = URLComponents(string: string)
        components?.queryItems = try? URLComponentsEncoder().encode(parameters)
        
        return components?.url
    }
    
    private enum Constants {
        static let imageSubPath = "/image/"
        static let fileSubPath = "/file/"
    }
}
