import CoreGraphics
import UIKit

struct EditorBarItemState: Equatable {
    let haveBackground: Bool
    let percentOfNavigationAppearance: CGFloat
    
    var backgroundAlpha: CGFloat {
        guard haveBackground else { return 0.0 }
        return 1.0 - percentOfNavigationAppearance
    }
    
    var textColor: UIColor {
        if haveBackground {
            if percentOfNavigationAppearance < 0.7 {
                return .textWhite
            } else {
                return .textPrimary.withAlphaComponent(percentOfNavigationAppearance)
            }
        }
        return .textPrimary
    }

    var hiddableTextColor: UIColor {
        if haveBackground { return .textWhite }
        return .textPrimary.withAlphaComponent(1 - percentOfNavigationAppearance)
    }
    
    static var initial = EditorBarItemState(haveBackground: false, percentOfNavigationAppearance: 0)
}
