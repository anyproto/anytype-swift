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
    func insets(_ insets: UIEdgeInsets) -> ViewCalculatorPaddingBox<Self> {
        ViewCalculatorPaddingBox(insets: insets, box: self)
    }
}



