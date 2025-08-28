import Foundation
import UIKit

struct ViewCalculatorSizeBox<T: ViewCalculator>: ViewCalculator {
    let width: CGFloat?
    let height: CGFloat?
    let box: T
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        let targetSize = CGSize(
            width: width ?? targetSize.width,
            height: height ?? targetSize.height
        )
        let size = box.sizeThatFits(targetSize)
        return CGSize(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }
    
    func setFrame(_ frame: CGRect) {
        box.setFrame(frame)
    }
    
    func layoutPriority() -> Float {
        box.layoutPriority()
    }
}

extension ViewCalculator {
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> some ViewCalculator {
        ViewCalculatorSizeBox(width: width, height: height, box: self)
    }
}



