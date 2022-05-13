import UIKit
import SwiftUI

protocol WindowHolder {
    
    func startNewRootView<ViewType: View>(_ view: ViewType)
            
    func presentOnTop(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
