import Foundation
import Services

protocol DownloadableContentProtocol {
    
    var contentUrl: URL? { get }
    
}

// MARK: - ImageMetadata

extension BlockFile: DownloadableContentProtocol {
    
    var contentUrl: URL? {
        guard metadata.targetObjectId.isNotEmpty else { return nil }
        switch contentType {
        case .image:
            return ImageMetadata(id: metadata.targetObjectId, side: .original).contentUrl
        default:
            return ContentUrlBuilder.fileUrl(fileId: metadata.targetObjectId)
        }
    }
}

extension ImageMetadata: DownloadableContentProtocol {
    var contentUrl: URL? {
        ContentUrlBuilder.imageUrl(imageMetadata: self)
    }
}
