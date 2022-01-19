import UIKit

final class FirstResponderHelper {
    
    private weak var scrollView: UIScrollView?
    private var keyboardFrame: CGRect?
    private var notificartionTokens = [NSObjectProtocol]()
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        let beginEditingToken = NotificationCenter.default.addObserver(forName: UITextView.textDidBeginEditingNotification, object: nil, queue: .main) { [weak self] notification in
            self?.textViewDidBeginEditing(with: notification)
        }
        let keyboardWillShowNotification = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillShowNotification(with: notification)
        }
        notificartionTokens.append(contentsOf: [beginEditingToken, keyboardWillShowNotification])
    }
    
    private func textViewDidBeginEditing(with notification: Notification) {
        guard
            let textView = notification.object as? UITextView,
            let window = textView.window,
            let selectedRange = textView.caretPosition,
            let keyboardFrame = keyboardFrame
        else {
            return
        }

        let cursorPosition = textView.caretRect(for: selectedRange)
        let globalCaretframe = textView.convert(cursorPosition, to: window)
        let distance: CGFloat = globalCaretframe.maxY - keyboardFrame.minY

        guard distance > -Constants.minSpacingAboveKeyboard else { return }
        UIView.animate(withDuration: CATransaction.animationDuration()) { [weak self] in
            self?.adjustScrollViewContentOffsetY(distance: distance)
        }
    }
    
    private func adjustScrollViewContentOffsetY(distance: CGFloat) {
        let newDistance: CGFloat = distance + Constants.minSpacingAboveKeyboard
        scrollView?.contentOffset.y += newDistance
    }
    
    private func keyboardWillShowNotification(with notification: Notification) {
        guard let isLocal = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? Bool,
              isLocal,
            let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        keyboardFrame = keyboardRect
    }
}

extension FirstResponderHelper {
    private enum Constants {
        static let minSpacingAboveKeyboard: CGFloat = 30
    }
}
