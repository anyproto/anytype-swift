import UIKit
import Combine

class KeyboardHeightListener {

    @Published var currentKeyboardHeight: CGFloat = 0
    @Published var currentKeyboardFrame: CGRect = .zero

    private var keyboardListenerHelper: KeyboardEventsListnerHelper?

    init() {
        self.keyboardListenerHelper = KeyboardEventsListnerHelper(
            willShowAction: { [weak self] notification in
                guard let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }

                self?.currentKeyboardHeight = keyboardRect.height
                self?.currentKeyboardFrame = keyboardRect
            },
            didChangeFrame: { [weak self] notification in
                guard let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey) else { return }

                self?.currentKeyboardHeight = keyboardRect.height
                self?.currentKeyboardFrame = keyboardRect
            },
            willHideAction: { [weak self] notification in
                self?.currentKeyboardHeight = 0
                self?.currentKeyboardFrame = .zero
            }
        )
    }
}
