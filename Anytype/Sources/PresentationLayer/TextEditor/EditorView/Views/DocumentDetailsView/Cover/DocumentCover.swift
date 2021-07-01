
import UIKit.UIColor

enum DocumentCover: Hashable {
    case imageId(String)
    case color(UIColor)
    case gradient(_ startColor: UIColor, _ endColor: UIColor)
    case preview(UIImage?)
}
