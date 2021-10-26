import UIKit

final class BindableGestureRecognizer: UITapGestureRecognizer {
    var action: ((BindableGestureRecognizer) -> Void)?

    init(action: ((BindableGestureRecognizer) -> Void)? = nil) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action?(self)
    }
}

extension UIView {
    /// A discrete gesture recognizer that interprets single or multiple taps.
    /// - Parameters:
    ///   - tapNumber: The number of taps necessary for gesture recognition.
    ///   - closure: A selector that identifies the method implemented by the target to handle the gesture recognized by the receiver. The action selector must conform to the signature described in the class overview. NULL is not a valid value.
    func addTapGesture(tapNumber: Int = 1, _ closure: ((BindableGestureRecognizer) -> Void)?) {
        guard let closure = closure else { return }

        let tap = BindableGestureRecognizer(action: closure)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)

        isUserInteractionEnabled = true
    }
}
