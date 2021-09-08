import UIKit.UIImage
import BlocksModels

enum ObjectIcon: Hashable {
    case icon(ObjectIconType, LayoutAlignment)
    case preview(ObjectIconPreviewType, LayoutAlignment)
}

enum ObjectIconPreviewType: Hashable {
    case basic(UIImage)
    case profile(UIImage)
}
