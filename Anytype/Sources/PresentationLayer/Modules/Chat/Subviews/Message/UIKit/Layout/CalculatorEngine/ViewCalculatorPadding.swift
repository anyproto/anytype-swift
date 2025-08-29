import Foundation
import UIKit

struct ViewCalculatorPaddingBox<T: ViewCalculator>: ViewCalculator {
    let insets: UIEdgeInsets
    let box: T
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        let targetSize = CGSize(width: targetSize.width - insets.left - insets.right, height: targetSize.height - insets.top - insets.bottom)
        let boxSize = box.sizeThatFits(targetSize)
        return CGSize(width: boxSize.width + insets.left + insets.right, height: boxSize.height + insets.top + insets.bottom)
    }
    
    func setFrame(_ frame: CGRect) {
        let frame = frame.inset(by: insets)
        box.setFrame(frame)
    }
    
    func layoutPriority() -> Float {
        box.layoutPriority()
    }
}

extension ViewCalculator {
    func padding(_ insets: UIEdgeInsets) -> some ViewCalculator {
        ViewCalculatorPaddingBox(insets: insets, box: self)
    }
    
    func padding(_ side: CGFloat) -> some ViewCalculator {
        let insets = UIEdgeInsets(top: side, left: side, bottom: side, right: side)
        return padding(insets)
    }
    
    func padding(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> some ViewCalculator {
        let insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return padding(insets)
    }
    
    func padding(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> some ViewCalculator {
        let insets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        return padding(insets)
    }
}



