import UIKit.UIImage
import BlocksModels

struct ObjectIcon: Hashable {
    let state: ObjectIconState
    let onTap: () -> ()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    static func == (lhs: ObjectIcon, rhs: ObjectIcon) -> Bool {
        lhs.state == rhs.state
    }
}

enum ObjectIconState: Hashable {
    case icon(DocumentIconType, LayoutAlignment)
    case preview(ObjectIconPreviewType, LayoutAlignment)
}

enum ObjectIconPreviewType: Hashable {
    case basic(UIImage)
    case profile(UIImage)
}
