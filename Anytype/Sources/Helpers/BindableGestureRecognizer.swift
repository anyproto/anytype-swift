import UIKit

final class BindableGestureRecognizer: UITapGestureRecognizer {
    var action: (() -> Void)?

    init(action: (() -> Void)? = nil) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action?()
    }
}
