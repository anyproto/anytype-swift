import Foundation
import UIKit

// Fix for https://app.clickup.com/t/1r67cww
// Must be removed when deployment ios version will be ios 15
final class iOS14SwiftUINavigationController: UINavigationController {
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {}
    
    func anytype_setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
    }
    
}
