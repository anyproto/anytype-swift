import Foundation
import UIKit

protocol UIHelpersDIProtocol {
    var toastPresenter: ToastPresenterProtocol { get }
    var viewControllerProvider: ViewControllerProviderProtocol { get }
    var commonNavigationContext: NavigationContextProtocol { get }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol
}

final class UIHelpersDI: UIHelpersDIProtocol {
        
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    // MARK: - UIHelpersDIProtocol
    
    let viewControllerProvider: ViewControllerProviderProtocol
    
    var toastPresenter: ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider,
            keyboardHeightListener: KeyboardHeightListener()
        )
    }
    
    var commonNavigationContext: NavigationContextProtocol {
        NavigationContext(rootViewController: viewControllerProvider.topViewController)
    }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider,
            containerViewController: containerViewController,
            keyboardHeightListener: KeyboardHeightListener()
        )
    }
}
