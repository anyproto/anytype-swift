import UIKit
import Combine

final class AnytypeAlertViewModel: AnytypePopupViewModelProtocol, ObservableObject {
    private(set) var popupLayout: AnytypePopupLayoutType
    private weak var popup: AnytypePopupProxy?
    private let contentView: UIView
    private let keyboardListener: KeyboardHeightListener
    private var keyboardHeightSubscription: AnyCancellable?
    private var showKeyboard: Bool

    init(
        contentView: UIView,
        keyboardListener: KeyboardHeightListener,
        popupLayout: AnytypePopupLayoutType = .alert(height: 0),
        showKeyboard: Bool = false
    ) {
        self.contentView = contentView
        self.popupLayout = popupLayout
        self.keyboardListener = keyboardListener
        self.showKeyboard = showKeyboard

        keyboardHeightSubscription = keyboardListener.$currentKeyboardHeight.sink { [weak self] in
            guard case .alert = self?.popupLayout else { return }
            self?.popupLayout = .alert(height: $0)
            self?.popup?.updateBottomInset()
        }
    }

    func viewDidUpdateHeight(_ height: CGFloat) {
        popup?.updateLayout(true)
    }

    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }

    func makeContentView() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = contentView

        return viewController
    }
    
    func willAppear() {
        guard showKeyboard else { return }
        contentView.becomeFirstResponder()
    }
}
