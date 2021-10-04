import UIKit.UIImage
import BlocksModels

struct ObjectHeaderIcon: Hashable {
    let icon: ObjectHeaderIconView.Model
    let layoutAlignment: LayoutAlignment
    
    let onTap: () -> Void
    
}

extension ObjectHeaderIcon {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(icon)
        hasher.combine(layoutAlignment)
    }
    
    static func == (lhs: ObjectHeaderIcon, rhs: ObjectHeaderIcon) -> Bool {
        lhs.icon == rhs.icon && lhs.layoutAlignment == rhs.layoutAlignment
    }
    
}
