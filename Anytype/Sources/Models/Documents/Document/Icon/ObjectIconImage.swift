import Foundation
import UIKit

enum ObjectIconImage: Hashable {
    case icon(ObjectIcon)
    case imageAsset(ImageAsset)
    case image(UIImage)
}
