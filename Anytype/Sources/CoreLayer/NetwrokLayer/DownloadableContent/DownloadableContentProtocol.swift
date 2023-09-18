import Foundation
import Services

protocol DownloadableContentProtocol {
    
    var contentUrl: URL? { get }
    
}

// MARK: - ImageMetadata

extension BlockFile: DownloadableContentProtocol {
    
    var contentUrl: URL? {
        switch contentType {
        case .image:
            return ImageMetadata(id: metadata.hash, width: .original).contentUrl
        default:
            return ContentUrlBuilder.fileUrl(fileId: metadata.hash)
        }
    }
}

extension ImageMetadata: DownloadableContentProtocol {
    var contentUrl: URL? {
        ContentUrlBuilder.imageUrl(imageMetadata: self)
    }
}
