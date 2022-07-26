import Foundation
import UIKit

enum ObjectIconImage: Hashable {
    case icon(ObjectIconType)
    case todo(Bool)
    case placeholder(Character?)
    // TODO: Delete me
    case staticImage(String)
    case imageAsset(ImageAsset)
    case image(UIImage)
}
