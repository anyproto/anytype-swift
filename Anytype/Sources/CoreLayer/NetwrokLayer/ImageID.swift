import Foundation
import  UIKit

struct ImageID {
    private let id: String
    private let width: ImageWidth
    
    init(id: String, width: ImageWidth) {
        self.id = id
        self.width = width
    }
}

extension ImageID {
    
    var resolvedUrl: URL? {
        UrlResolver.resolvedUrl(.image(id: id, width: width))
    }
    
}
