import CoreGraphics
import UIKit

struct EditorBarItemState: Equatable {
    let haveBackground: Bool
    let opacity: CGFloat
    
    var backgroundAlpha: CGFloat {
        guard haveBackground else { return 0.0 }
        return 1.0 - opacity
    }
    
    var buttonTintColor: UIColor {
        if haveBackground {
            if opacity < 0.7 {
                return .Text.white
            } else {
                return .Control.secondary.withAlphaComponent(opacity)
            }
        }
        return .Control.secondary
    }
    
    var buttonTextColor: UIColor {
        if haveBackground {
            if opacity < 0.7 {
                return .Text.white
            } else {
                return .Text.primary.withAlphaComponent(opacity)
            }
        }
        return .Text.primary
    }
    
    static let initial = EditorBarItemState(haveBackground: false, opacity: 0)
}
