import Foundation
import AnytypeCore
import UIKit

final class UrlResolver {
       
    static func resolvedUrl(_ urlType: UrlType) -> URL? {
        guard let gatewayUrl = MiddlewareConfigurationService.shared.configuration?.gatewayURL else {
            anytypeAssertionFailure("Configuration must be loaded")
            return nil
        }
        
        guard let components = URLComponents(string: gatewayUrl) else {
            return nil
        }
        
        switch urlType {
        case let .file(id):
            return makeFileUrl(initialComponents: components, fileId: id)
        case let .image(id, width):
            return makeImageUrl(initialComponents: components, imageId: id, width: width)
        }
    }
    
}

private extension UrlResolver {
    
    static func makeFileUrl(initialComponents: URLComponents, fileId: String) -> URL? {
        guard !fileId.isEmpty else { return nil }
        
        var components = initialComponents
        components.path = "\(Constants.fileSubPath)/\(fileId)"
        
        return components.url
    }
    
    static func makeImageUrl(initialComponents: URLComponents, imageId: String, width: CGFloat?) -> URL? {
        guard !imageId.isEmpty else { return nil }
        
        var components = initialComponents
        components.path = "\(Constants.imageSubPath)/\(imageId)"
        
        guard let width = width else {
            return components.url
        }
        
        let calculatedWidth = Int(width * UIScreen.main.scale)
        
        if calculatedWidth > 0 {
            components.queryItems = [
                URLQueryItem(name: "width", value: "\(calculatedWidth)")
            ]
        } else {
            components.queryItems = [
                URLQueryItem(name: "width", value: "700")
            ]
        }
        
        return components.url
    }
    
}

extension UrlResolver {
    
    enum UrlType {
        case file(id: String)
        case image(id: String, width: CGFloat?)
    }
    
}

private extension UrlResolver {
    
    enum Constants {
        static let imageSubPath = "/image"
        static let fileSubPath = "/file"
    }
    
}
