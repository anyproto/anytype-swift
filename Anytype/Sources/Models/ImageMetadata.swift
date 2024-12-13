import Foundation
import UIKit
import Services

struct ImageMetadata {
    let id: String
    let width: ImageWidth
}

extension ImageMetadata {
    
    init(id: String, width: CGFloat) {
        self.id = id
        self.width = .width(width)
    }
    
}

extension FileDetails {
    public var contentUrl: URL? {
        switch fileContentType {
        case .image:
            return ImageMetadata(id: id, width: .original).contentUrl
        default:
            return ContentUrlBuilder.fileUrl(fileId: id)
        }
    }
}
