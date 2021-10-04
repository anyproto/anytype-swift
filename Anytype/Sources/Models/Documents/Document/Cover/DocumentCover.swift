
import UIKit.UIColor

enum DocumentCover: Hashable {
    case imageId(String)
    case color(UIColor)
    case gradient(GradientColor)
}
