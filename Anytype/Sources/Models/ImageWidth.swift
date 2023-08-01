import Foundation
import UIKit

enum ImageWidth {
    case width(CGFloat)
    case original
}

extension CGFloat {
    
    var asImageWidth: ImageWidth {
        ImageWidth.width(self)
    }
    
}
