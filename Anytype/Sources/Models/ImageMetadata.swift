import Foundation
import UIKit

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
