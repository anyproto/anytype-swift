import Foundation
import SwiftUI

final class AnytypeNavigationCoordinator: NSObject, UINavigationControllerDelegate {
    
    @Binding private(set) var path: [AnyHashable]
    @Binding private(set) var pathChanging: Bool
    
    let builder = AnytypeDestinationBuilderHolder()
    var currentViewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
    var numberOfTransactions: Int = 0
    
    init(path: Binding<[AnyHashable]>, pathChanging: Binding<Bool>) {
        self._path = path
        self._pathChanging = pathChanging
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        pathChanging = true
        navigationController.transitionCoordinator?.notifyWhenInteractionChanges { [weak self] transaction in
            if transaction.isCancelled {
                self?.pathChanging = false
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if numberOfTransactions > 0 {
            numberOfTransactions -= 1
        }
        
        if numberOfTransactions == 0  {
            if navigationController.viewControllers.count < path.count {
                path = Array(path[..<navigationController.viewControllers.count])
            }
            if navigationController.viewControllers.count < currentViewControllers.count {
                currentViewControllers = Array(currentViewControllers[..<navigationController.viewControllers.count])
            }
        }
        
        pathChanging = false
    }
}
