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
                return .textWhite
            } else {
                return .buttonActive.withAlphaComponent(opacity)
            }
        }
        return .buttonActive
    }

    var hiddableTextColor: UIColor {
        let color: UIColor = haveBackground ? .textWhite : .textSecondary
        return color.withAlphaComponent(1 - opacity)
    }
    
    static var initial = EditorBarItemState(haveBackground: false, opacity: 0)
}
