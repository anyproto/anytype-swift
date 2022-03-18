import CoreGraphics
import UIKit

struct EditorBarItemState: Equatable {
    let haveBackground: Bool
    let percentOfNavigationAppearance: CGFloat
    
    var backgroundAlpha: CGFloat {
        guard haveBackground else { return 0.0 }
        return 1.0 - percentOfNavigationAppearance
    }
    
    var buttonTintColor: UIColor {
        if haveBackground {
            if percentOfNavigationAppearance < 0.7 {
                return .textWhite
            } else {
                return .buttonActive.withAlphaComponent(percentOfNavigationAppearance)
            }
        }
        return .buttonActive
    }

    var hiddableTextColor: UIColor {
        let color: UIColor = haveBackground ? .textWhite : .textSecondary
        return color.withAlphaComponent(1 - percentOfNavigationAppearance)
    }
    
    static var initial = EditorBarItemState(haveBackground: false, percentOfNavigationAppearance: 0)
}
