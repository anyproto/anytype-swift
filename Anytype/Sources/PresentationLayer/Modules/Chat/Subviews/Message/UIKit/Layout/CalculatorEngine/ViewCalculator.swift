import Foundation
import UIKit

protocol ViewCalculator {
    func sizeThatFits(_ targetSize: CGSize) -> CGSize
    func setFrame(_ frame: CGRect)
    func layoutPriority() -> Float
}

extension ViewCalculator {
    func layoutPriority() -> Float { .zero }
}

extension ViewCalculator {
    func calculate(_ targetSize: CGSize) {
        let size = sizeThatFits(targetSize)
        setFrame(CGRect(origin: .zero, size: size))
    }
}
