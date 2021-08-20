import UIKit
import SwiftUI

protocol MainWindowHolder {
    
    var rootNavigationController: UINavigationController { get }
    
    func startNewRootView<ViewType: View>(_ view: ViewType)
        
    func configureMiddlewareConfiguration()
    
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension MainWindowHolder {
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool) {
        self.presentOnTop(viewControllerToPresent, animated: flag, completion: nil)
    }
}
