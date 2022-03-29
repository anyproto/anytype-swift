import Foundation
import UIKit

enum ImageWidth {
    case custom(CGFloat)
    case original
}

extension CGFloat {
    
    var asImageWidth: ImageWidth {
        ImageWidth.custom(self)
    }
    
}
