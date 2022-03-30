import Foundation
import BlocksModels

protocol DownloadableContentProtocol {
    
    var contentUrl: URL? { get }
    
}

// MARK: - ImageMetadata

extension ImageMetadata: DownloadableContentProtocol {
    
    var contentUrl: URL? {
        ContentUrlBuilder.imageUrl(imageMetadata: self)
    }
    
}

// MARK: - FileMetadata

extension FileMetadata: DownloadableContentProtocol {
    
    var contentUrl: URL? {
        ContentUrlBuilder.fileUrl(fileId: self.hash)
    }
    
}
