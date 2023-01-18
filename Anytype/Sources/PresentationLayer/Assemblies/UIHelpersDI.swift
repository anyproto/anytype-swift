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
        toastPresenter(using: nil)
    }
    
    var commonNavigationContext: NavigationContextProtocol {
        NavigationContext(window: viewControllerProvider.window)
    }
    
    func toastPresenter(using containerViewController: UIViewController?) -> ToastPresenterProtocol {
        ToastPresenter(
            viewControllerProvider: viewControllerProvider,
            containerViewController: containerViewController,
            keyboardHeightListener: KeyboardHeightListener()
        )
    }
}
