import Foundation
import UIKit

enum ObjectIconImage: Hashable {
    case icon(ObjectIconType)
    case todo(Bool)
    case placeholder(Character?)
    case staticImage(String)
    // TODO: Align ImageSource, ObjectIconImage
    case image(UIImage)
}
