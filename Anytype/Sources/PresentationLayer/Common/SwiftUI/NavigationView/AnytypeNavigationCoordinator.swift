import Foundation
import SwiftUI

final class AnytypeNavigationCoordinator: NSObject, UINavigationControllerDelegate {
    
    @Binding private(set) var path: [AnyHashable]
    
    let builder = AnytypeDestinationBuilderHolder()
    var currentViewControllers = [UIHostingController<AnytypeNavigationViewBridge>]()
    var numberOfTransactions: Int = 0
    
    init(path: Binding<[AnyHashable]>) {
        self._path = path
    }
    
    // MARK: - UINavigationControllerDelegate
    
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
    }
}
