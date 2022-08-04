import Foundation
import UIKit

enum ObjectIconImage: Hashable {
    case icon(ObjectIconType)
    case todo(Bool)
    case placeholder(Character?)
    case imageAsset(ImageAsset)
    case image(UIImage)
}
