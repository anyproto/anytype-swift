import UIKit
import Combine

final class AnytypeAlertViewModel: AnytypePopupViewModelProtocol, ObservableObject {
    private(set) var popupLayout: AnytypePopupLayoutType
    private weak var popup: AnytypePopupProxy?
    private let contentView: UIView
    private let keyboardListener: KeyboardHeightListener
    private var keyboardHeightSubscription: AnyCancellable?

    init(contentView: UIView, keyboardListener: KeyboardHeightListener) {
        self.contentView = contentView
        self.popupLayout = .alert(height: 0)
        self.keyboardListener = keyboardListener

        keyboardHeightSubscription = keyboardListener.$currentKeyboardHeight.sink { [weak self] in
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
}
