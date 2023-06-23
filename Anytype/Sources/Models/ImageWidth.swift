import Foundation
import UIKit

enum ImageWidth {
    case width(CGFloat)
    case height(CGFloat)
    case size(CGSize)
    case original
}

extension CGFloat {
    
    var asImageWidth: ImageWidth {
        ImageWidth.width(self)
    }
    
}
