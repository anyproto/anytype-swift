import Foundation
import UIKit

enum Icon: Hashable, Equatable {
    case object(ObjectIcon)
    
    // Container
    case cycle(Icon.Content)
    case square(Icon.Content)
    case squareDynamic(Icon.Content)
    case squircle(Icon.Content)
    
    // Without Container
    case asset(ImageAsset)
    case image(UIImage)
}

extension Icon {
    enum Content: Hashable, Equatable {
        case char(String)
        case asset(ImageAsset)
        case image(UIImage)
        case imageId(String)
    }
}
