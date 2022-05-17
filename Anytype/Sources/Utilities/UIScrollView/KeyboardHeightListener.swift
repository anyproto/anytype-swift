import UIKit
import Combine

final class KeyboardHeightListener {

    @Published var currentKeyboardHeight: CGFloat = 0
    private var keyboardListenerHelper: KeyboardEventsListnerHelper?

    init() {
        self.keyboardListenerHelper = KeyboardEventsListnerHelper(
            willShowAction: { [weak self] notification in
                guard let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }

                self?.currentKeyboardHeight = keyboardRect.height
            },
            didChangeFrame: { [weak self] notification in
                guard let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }

                self?.currentKeyboardHeight = keyboardRect.height
            },
            willHideAction: { [weak self] notification in
                self?.currentKeyboardHeight = 0
            }
        )
    }
}
