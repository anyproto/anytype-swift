import Foundation
import UIKit

struct ImageMetadata {
    
    private let id: String
    private let width: ImageWidth
    
    init(id: String, width: ImageWidth) {
        self.id = id
        self.width = width
    }
}

extension ImageMetadata: DownloadableContentProtocol {
    
    var downloadingUrl: URL? {
        UrlResolver.resolvedUrl(.image(id: id, width: width))
    }
    
}
