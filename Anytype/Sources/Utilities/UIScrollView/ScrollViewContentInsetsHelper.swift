import UIKit

final class ScrollViewContentInsetsHelper: KeyboardEventsListnerHelper {
    private struct EditorScrollViewConstants {
        static let bottomEditorInsets: CGFloat = 150
    }
    
    init?(scrollView: UIScrollView) {
        scrollView.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
        let showAction: Action = { [weak scrollView] notification in
            guard let keyboardRect = notification.keyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }
            scrollView?.handleBottomInsetChange(keyboardRect.height)
        }
        let willHideAction: Action = { [weak scrollView] _ in
            scrollView?.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
        }
        super.init(willShowAction: showAction,
                   willChangeFrame: showAction,
                   willHideAction: willHideAction)
    }
}

private extension UIScrollView {
    
    func handleBottomInsetChange(_ keyboardHeight: CGFloat) {
        guard contentInset.bottom != keyboardHeight else { return }
        contentInset.bottom = keyboardHeight
        verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
}

private extension Notification {
    
    func keyboardRect(for key: String) -> CGRect? {
        guard let isLocal = userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber, isLocal.boolValue else {
            return nil
        }
        guard let frameValue = userInfo?[key] as? NSValue else {
            return nil
        }
        return frameValue.cgRectValue
    }
}
