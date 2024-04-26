import Foundation
import UIKit

protocol UIHelpersDIProtocol {
    func toastPresenter() -> ToastPresenterProtocol
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol
    func viewControllerProvider() -> ViewControllerProviderProtocol
    func commonNavigationContext() -> NavigationContextProtocol
    func alertOpener() -> AlertOpenerProtocol
    func urlOpener() -> URLOpenerProtocol
}

final class UIHelpersDI: UIHelpersDIProtocol {
    
    private let _viewControllerProvider: ViewControllerProviderProtocol
    private let serviceLocator: ServiceLocator
    
    init(viewControllerProvider: ViewControllerProviderProtocol, serviceLocator: ServiceLocator) {
        self._viewControllerProvider = viewControllerProvider
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - UIHelpersDIProtocol
    
    func toastPresenter() -> ToastPresenterProtocol {
        toastPresenter(using: nil)
    }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider(),
            containerViewController: containerViewController,
            keyboardHeightListener: KeyboardHeightListener(),
            documentsProvider: serviceLocator.documentsProvider
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
    
    func urlOpener() -> URLOpenerProtocol {
        URLOpener(navigationContext: commonNavigationContext())
    }
}
