import UIKit
import Combine

final class ScrollViewContentInsetsHelper: KeyboardEventsListnerHelper {
    private struct EditorScrollViewConstants {
        static let bottomEditorInsets: CGFloat = 150
        static let movingInsents: UIEdgeInsets =
            .init(
                top: UIScreen.main.bounds.height / 4,
                left: 0,
                bottom: UIScreen.main.bounds.height / 2,
                right: 0
            )
    }
    private weak var scrollView: UIScrollView?
    private var cancellables = [AnyCancellable]()

    init?(scrollView: UIScrollView, stateManager: EditorPageBlocksStateManagerProtocol) {
        scrollView.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
        let showAction: Action = { [weak scrollView] notification in
            guard let keyboardRect = notification.keyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }
            scrollView?.handleBottomInsetChange(keyboardRect.height)
        }
        let willHideAction: Action = { [weak scrollView] _ in
            scrollView?.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
        }

        stateManager.editorEditingState.sink { [weak scrollView] state in
            switch state {
            case .editing, .selecting:
                scrollView?.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
            case .moving:
                scrollView?.contentInset = EditorScrollViewConstants.movingInsents
            }
        }.store(in: &cancellables)
        self.scrollView = scrollView

        super.init(willShowAction: showAction,
                   willChangeFrame: showAction,
                   willHideAction: willHideAction)
    }

    func restoreEditingOffset() {
        scrollView?.handleBottomInsetChange(EditorScrollViewConstants.bottomEditorInsets)
    }
}

private extension UIScrollView {

    func handleBottomInsetChange(_ keyboardHeight: CGFloat) {
        guard contentInset.bottom != keyboardHeight else { return }
        contentInset.bottom = keyboardHeight
        contentInset.top = 0
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

