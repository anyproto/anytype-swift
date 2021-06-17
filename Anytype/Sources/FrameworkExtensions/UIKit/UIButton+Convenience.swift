
import UIKit

extension UIButton {
    
    func setImageAndTitleSpacing(_ spacing: CGFloat) {
        let insetAmount = spacing / 2.0
        self.imageEdgeInsets = UIEdgeInsets(top: self.imageEdgeInsets.top,
                                            left: -insetAmount,
                                            bottom: self.imageEdgeInsets.bottom,
                                            right: insetAmount)
        
        self.titleEdgeInsets = UIEdgeInsets(top: self.titleEdgeInsets.top,
                                            left: insetAmount,
                                            bottom: self.titleEdgeInsets.bottom,
                                            right: -insetAmount)
        self.contentEdgeInsets = UIEdgeInsets(top: self.contentEdgeInsets.top,
                                              left: insetAmount,
                                              bottom: self.contentEdgeInsets.bottom,
                                              right: insetAmount)
    }
}

