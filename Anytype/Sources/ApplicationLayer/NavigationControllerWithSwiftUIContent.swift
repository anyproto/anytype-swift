import Foundation
import UIKit

// Delete with FeatureFlags.homeWidgets

// Fix for https://app.clickup.com/t/1r67cww
// and https://app.clickup.com/t/2e4uerh
final class NavigationControllerWithSwiftUIContent: UINavigationController {
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {}
    
    func anytype_setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
    }
    
}
