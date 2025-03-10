import UIKit

public struct InsetConstraints {
    let leadingConstraint: NSLayoutConstraint
    let trailingConstraint: NSLayoutConstraint
    let topConstraint: NSLayoutConstraint
    let bottomConstraint: NSLayoutConstraint

    @MainActor
    func update(with insets: UIEdgeInsets) {
        leadingConstraint.constant = insets.left
        trailingConstraint.constant = -insets.right
        bottomConstraint.constant = -insets.bottom
        topConstraint.constant = insets.top

        [leadingConstraint, topConstraint, trailingConstraint, bottomConstraint].forEach {
            $0.isActive = true
        }
    }
}
