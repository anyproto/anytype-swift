import Foundation
import BlocksModels
import SwiftUI
import Combine
import FloatingPanel

final class SetFiltersDaysViewModel: TextRelationDetailsViewModelProtocol {
    let value: String
    let title: String
    let isEditable = true
    let type: TextRelationDetailsViewType = .numberOfDays
    let actionButtonViewModel: TextRelationActionButtonViewModel? = nil
    let actionsViewModel: [TextRelationActionViewModelProtocol] = []
    let onValueChanged: (String) -> Void
    
    weak var viewController: TextRelationDetailsViewController?
    
    private weak var popup: AnytypePopupProxy?
    private(set) var popupLayout: AnytypePopupLayoutType = .intrinsic {
        didSet {
            popup?.updateLayout(false)
        }
    }
    
    private let keyboardHeightListener = KeyboardHeightListener()
    private var keyboardHeightSubscription: AnyCancellable?

    // MARK: - Initializers
    
    init(title: String, value: String, onValueChanged: @escaping (String) -> Void) {
        self.title = title
        self.value = value
        self.onValueChanged = onValueChanged

        setupKeyboardListener()
    }
    
    func updateValue(_ text: String) {
        onValueChanged(text)
    }
}

extension SetFiltersDaysViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        let vc = TextRelationDetailsViewController(viewModel: self)
        self.viewController = vc
        return vc
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
    func updatePopupLayout(_ layoutGuide: UILayoutGuide) {
        self.popupLayout = .adaptiveTextRelationDetails(layoutGuide: layoutGuide)
    }
}

private extension SetFiltersDaysViewModel {
    
    func setupKeyboardListener() {
        keyboardHeightSubscription = keyboardHeightListener.$currentKeyboardHeight.sink { [weak self] height in
            self?.adjustViewHeightBy(keyboardHeight: height)
        }
    }
    
    func adjustViewHeightBy(keyboardHeight: CGFloat) {
        viewController?.keyboardDidUpdateHeight(keyboardHeight)
        popup?.updateLayout(true)
    }
}
