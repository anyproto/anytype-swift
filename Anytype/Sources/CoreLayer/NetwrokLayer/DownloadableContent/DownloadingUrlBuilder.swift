import Foundation
import AnytypeCore
import UIKit

final class DownloadingUrlBuilder {
       
    static func fileUrl(fileId: String) -> URL? {
        guard fileId.isNotEmpty else {
            anytypeAssertionFailure("File id is nil", domain: .downloadingUrlBuilder)
            return nil
        }
        
        let gatewayUrl = MiddlewareConfigurationProvider.shared.configuration.gatewayURL
        guard let components = URLComponents(string: gatewayUrl) else {
            anytypeAssertionFailure("File url components is nil. GatewayUrl: \(gatewayUrl)", domain: .downloadingUrlBuilder)
            return nil
        }
        
        return makeFileUrl(initialComponents: components, fileId: fileId)
    }
    
    static func imageUrl(imageMetadata: ImageMetadata) -> URL? {
        guard imageMetadata.id.isNotEmpty else {
            anytypeAssertionFailure("Image id is nil", domain: .downloadingUrlBuilder)
            return nil
        }
        
        let gatewayUrl = MiddlewareConfigurationProvider.shared.configuration.gatewayURL
        guard let components = URLComponents(string: gatewayUrl) else {
            anytypeAssertionFailure("Image url components is nil. GatewayUrl: \(gatewayUrl)", domain: .downloadingUrlBuilder)
            return nil
        }
        
        return makeImageUrl(initialComponents: components, imageMetadata: imageMetadata)
    }
    
}

// MARK: - Private extension

private extension DownloadingUrlBuilder {
    
    static func makeFileUrl(initialComponents: URLComponents, fileId: String) -> URL? {
        var components = initialComponents
        components.path = "\(Constants.fileSubPath)\(fileId)"
        
        return components.url
    }
    
    static func makeImageUrl(initialComponents: URLComponents, imageMetadata: ImageMetadata) -> URL? {
        var components = initialComponents
        components.path = "\(Constants.imageSubPath)\(imageMetadata.id)"
        
        switch imageMetadata.width {
        case .custom(let width):
            components.queryItems = [makeCustomWidthQueryItem(width: width)]
            return components.url
        case .original:
            return components.url
        }
    }
    
    static func makeCustomWidthQueryItem(width: CGFloat) -> URLQueryItem {
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

// MARK: - Constants

private extension DownloadingUrlBuilder {
    
    enum Constants {
        static let imageSubPath = "/image/"
        static let fileSubPath = "/file/"
        
        static let widthQueryItemName = "width"
        static let defaultWidth = "700"
        
    }
    
}
