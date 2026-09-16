import UIKit

@MainActor
final class QuickCaptureInputObserver: NSObject, UITextViewDelegate {
    private weak var textView: UITextView?
    private weak var originalDelegate: (any UITextViewDelegate)?
    private var onInput: (() -> Void)?

    func observe(_ textView: UITextView, onInput: @escaping () -> Void) {
        stopObserving()
        self.textView = textView
        originalDelegate = textView.delegate
        self.onInput = onInput
        textView.delegate = self
    }

    func stopObserving() {
        if textView?.delegate === self { textView?.delegate = originalDelegate }
        textView = nil
        originalDelegate = nil
        onInput = nil
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let delegate = originalDelegate
        onInput?()
        stopObserving()
        return delegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    override func responds(to selector: Selector!) -> Bool {
        if super.responds(to: selector) { return true }
        return MainActor.assumeIsolated { originalDelegate?.responds(to: selector) == true }
    }

    override func forwardingTarget(for selector: Selector!) -> Any? {
        if let delegate = MainActor.assumeIsolated({ originalDelegate }), delegate.responds(to: selector) {
            return delegate
        }
        return super.forwardingTarget(for: selector)
    }
}
