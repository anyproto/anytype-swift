import Foundation
import UIKit

struct ViewCalculatorFrameWriterBox<T: ViewCalculator>: ViewCalculator {
    
    let frameWriter: (CGRect) -> Void
    let box: T
    
    func sizeThatFits(_ targetSize: CGSize) -> CGSize {
        box.sizeThatFits(targetSize)
    }
    
    func setFrame(_ frame: CGRect) {
        frameWriter(frame)
        box.setFrame(frame)
    }
    
    func layoutPriority() -> Float {
        box.layoutPriority()
    }
}

extension ViewCalculator {
    func readFrame(_ frameWriter: @escaping (CGRect) -> Void) -> some ViewCalculator {
        ViewCalculatorFrameWriterBox(frameWriter: frameWriter, box: self)
    }
}
