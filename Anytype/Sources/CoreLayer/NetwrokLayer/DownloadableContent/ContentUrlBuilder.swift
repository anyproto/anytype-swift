import Foundation
import AnytypeCore
import UIKit

final class ContentUrlBuilder {
    
    private static var middlewareConfigurationProvider: any MiddlewareConfigurationProviderProtocol {
        return Container.shared.middlewareConfigurationProvider.resolve()
    }
    
    static func fileUrl(fileId: String) -> URL? {
        guard fileId.isNotEmpty else {
            anytypeAssertionFailure("File id is empty")
            return nil
        }
        
        let gatewayUrl = middlewareConfigurationProvider.configuration.gatewayURL
        guard let components = URLComponents(string: gatewayUrl) else {
            anytypeAssertionFailure("File url components is nil", info: ["gatewayUrl": gatewayUrl])
            return nil
        }
        
        return makeFileUrl(initialComponents: components, fileId: fileId)
    }
    
    static func imageUrl(imageMetadata: ImageMetadata) -> URL? {
        guard imageMetadata.id.isNotEmpty else {
            anytypeAssertionFailure("Image id is empty")
            return nil
        }
        
        let gatewayUrl = middlewareConfigurationProvider.configuration.gatewayURL
        guard let components = URLComponents(string: gatewayUrl) else {
            anytypeAssertionFailure("Image url components is nil", info: ["gatewayUrl": gatewayUrl])
            return nil
        }
        
        return makeImageUrl(initialComponents: components, imageMetadata: imageMetadata)
    }
    
}

// MARK: - Private extension

private extension ContentUrlBuilder {
    
    // Middleware have only this sizes + original
    private static let widthSizes: [CGFloat] = [320, 1920]
    
    static func makeFileUrl(initialComponents: URLComponents, fileId: String) -> URL? {
        var components = initialComponents
        components.path = "\(Constants.fileSubPath)\(fileId)"
        
        return components.url
    }
    
    static func makeImageUrl(initialComponents: URLComponents, imageMetadata: ImageMetadata) -> URL? {
        var components = initialComponents
        components.path = "\(Constants.imageSubPath)\(imageMetadata.id)"
        
        switch imageMetadata.side {
        case .width(let width):
            let width = width * ScaleProvider.shared.scale
            let size = widthSizes.first { width <= $0 }
            if let size {
                components.queryItems = [makeCustomSideQueryItem(size: size, name: Constants.widthQueryItemName)]
            }
            return components.url
        case .original:
            return components.url
        }
    }
    
    private static func makeCustomSideQueryItem(size: CGFloat, name: String) -> URLQueryItem {
        let queryItemValue: String = {
            guard size > 0 else {
                return Constants.defaultSize
            }
            
            return "\(Int(size))"
        }()
        
        return URLQueryItem(name: name, value: queryItemValue)
    }
}

// MARK: - Constants

private extension ContentUrlBuilder {
    
    enum Constants {
        static let imageSubPath = "/image/"
        static let fileSubPath = "/file/"
        
        static let widthQueryItemName = "width"
        static let defaultSize = "1920"
        
    }
    
}
