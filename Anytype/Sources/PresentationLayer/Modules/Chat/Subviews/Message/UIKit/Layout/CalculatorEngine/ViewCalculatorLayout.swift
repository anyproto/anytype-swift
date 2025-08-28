import Foundation
import UIKit

struct ViewCalculatorLayoutPriorityBox<T: ViewCalculator>: ViewCalculator {
    let priority: Float
    let box: T
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        box.sizeThatFits(targetSize)
    }
    
    func setFrame(_ frame: CGRect) {
        box.setFrame(frame)
    }
    
    func layoutPriority() -> Float {
        priority
    }
}

extension ViewCalculator {
    func layoutPriority(_ priority: Float) -> ViewCalculatorLayoutPriorityBox<Self> {
        ViewCalculatorLayoutPriorityBox(priority: priority, box: self)
    }
}
