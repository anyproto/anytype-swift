import UIKit
import SwiftUI

protocol WindowHolder {
    var rootNavigationController: UINavigationController { get }
    
    func startNewRootView<ViewType: View>(_ view: ViewType)
            
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
