import Foundation
import AnytypeCore
import UIKit

final class UrlResolver {
       
    static func resolvedUrl(_ urlType: UrlType) -> URL? {
        let gatewayUrl = MiddlewareConfigurationProvider.shared.configuration.gatewayURL
        
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
    
    static func makeImageUrl(initialComponents: URLComponents, imageId: String, width: ImageWidth) -> URL? {
        guard !imageId.isEmpty else { return nil }
        
        var components = initialComponents
        components.path = "\(Constants.imageSubPath)/\(imageId)"
        
        switch width {
        case .custom(let width):
            components.queryItems = [makeCustomWidthQueryItem(width: width)]
            return components.url
        case .original:
            return components.url
        }
    }
    
    private static func makeCustomWidthQueryItem(width: CGFloat) -> URLQueryItem {
        let adjustedWidth = Int(width * UIScreen.main.scale)
        
        let queryItemValue: String = {
            guard adjustedWidth > 0 else {
                return Constants.defaultWidth
            }
            
            return "\(adjustedWidth)"
        }()
        
        return URLQueryItem(name: Constants.widthQueryItemName, value: queryItemValue)
    }
    
}

extension UrlResolver {
    
    enum UrlType {
        case file(id: String)
        case image(id: String, width: ImageWidth)
    }
    
}

private extension UrlResolver {
    
    enum Constants {
        static let imageSubPath = "/image"
        static let fileSubPath = "/file"
        
        static let widthQueryItemName = "width"
        static let defaultWidth = "700"
        
    }
    
}
