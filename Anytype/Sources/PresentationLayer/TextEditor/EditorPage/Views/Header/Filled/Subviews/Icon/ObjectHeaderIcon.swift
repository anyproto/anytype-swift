import UIKit.UIImage
import Services

struct ObjectHeaderIcon: Hashable {
    let icon: ObjectHeaderIconView.Model
    let layoutAlignment: LayoutAlignment
    
    @EquatableNoop private(set) var onTap: () -> Void
}
