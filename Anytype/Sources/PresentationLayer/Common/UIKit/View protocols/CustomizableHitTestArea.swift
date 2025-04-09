import UIKit


protocol CustomizableHitTestAreaView: UIView {
    @MainActor
    var minHitTestArea: CGSize { get }
}

extension CustomizableHitTestAreaView {
    @MainActor
    func containsCustomHitTestArea(_ point: CGPoint) -> Bool {
        let dX: CGFloat = max(minHitTestArea.width - bounds.width, 0.0) / 2.0
        let dY: CGFloat = max(minHitTestArea.height - bounds.height, 0.0) / 2.0

        return bounds.insetBy(dx: -dX, dy: -dY).contains(point)
    }
}
