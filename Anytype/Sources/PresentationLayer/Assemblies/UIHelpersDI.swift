import Foundation
import UIKit

protocol UIHelpersDIProtocol {
    var toastPresenter: ToastPresenterProtocol { get }
    var viewControllerProvider: ViewControllerProviderProtocol { get }
}

final class UIHelpersDI: UIHelpersDIProtocol {
        
    init(viewControllerProvider: ViewControllerProviderProtocol) {
        self.viewControllerProvider = viewControllerProvider
    }
    
    // MARK: - UIHelpersDIProtocol
    
    let viewControllerProvider: ViewControllerProviderProtocol
    
    var toastPresenter: ToastPresenterProtocol {
        ToastPresenter(viewControllerProvider: viewControllerProvider)
    }
}
