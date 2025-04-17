import Foundation
import UIKit

struct ImageMetadata {
    let id: String
    let side: ImageSide
}

extension ImageMetadata {
    
    init(id: String, width: CGFloat) {
        self.id = id
        self.side = .width(width)
    }
    
}
