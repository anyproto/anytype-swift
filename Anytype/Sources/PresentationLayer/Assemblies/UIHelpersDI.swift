import Foundation
import UIKit

protocol UIHelpersDIProtocol {
    func toastPresenter() -> ToastPresenterProtocol
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol
    func viewControllerProvider() -> ViewControllerProviderProtocol
    func commonNavigationContext() -> NavigationContextProtocol
    func alertOpener() -> AlertOpenerProtocol
    
}

final class UIHelpersDI: UIHelpersDIProtocol {
    
    private let _viewControllerProvider: ViewControllerProviderProtocol
    
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self._viewControllerProvider = viewControllerProvider
    }
    
    // MARK: - UIHelpersDIProtocol
    
    func toastPresenter() -> ToastPresenterProtocol {
        toastPresenter(using: nil)
    }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider(),
            containerViewController: containerViewController,
            keyboardHeightListener: KeyboardHeightListener()
        )
    }
    
    func viewControllerProvider() -> ViewControllerProviderProtocol {
        return _viewControllerProvider
    }
    
    func commonNavigationContext() -> NavigationContextProtocol {
        NavigationContext(window: viewControllerProvider().window)
    }
    
    func alertOpener() -> AlertOpenerProtocol {
        AlertOpener(navigationContext: commonNavigationContext())
    }
}
