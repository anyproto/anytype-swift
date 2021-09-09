import UIKit.UIImage
import BlocksModels

// FIXME: Make ObjectIcon as a struct and use NewObjectIconView.Model
enum ObjectIcon: Hashable {
    case icon(ObjectIconType, LayoutAlignment)
    case preview(ObjectIconPreviewType, LayoutAlignment)
}

enum ObjectIconPreviewType: Hashable {
    case basic(UIImage)
    case profile(UIImage)
}
