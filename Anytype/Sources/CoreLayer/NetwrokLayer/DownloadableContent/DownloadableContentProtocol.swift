import Foundation
import BlocksModels

protocol DownloadableContentProtocol {
    
    var downloadingUrl: URL? { get }
    
}

// MARK: - ImageMetadata

extension ImageMetadata: DownloadableContentProtocol {
    
    var downloadingUrl: URL? {
        DownloadingUrlBuilder.imageUrl(imageMetadata: self)
    }
    
}

// MARK: - FileMetadata

extension FileMetadata: DownloadableContentProtocol {
    
    var downloadingUrl: URL? {
        DownloadingUrlBuilder.fileUrl(fileId: self.hash)
    }
    
}
