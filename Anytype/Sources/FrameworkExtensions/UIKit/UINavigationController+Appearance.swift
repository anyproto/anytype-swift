import UIKit

extension UINavigationController {
    func modifyBarAppearance(
        _ appearance: UINavigationBarAppearance
    ) {
        navigationBar.compactAppearance = appearance
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = appearance
        }
        navigationBar.barTintColor = UIColor.backgroundPrimary
        navigationBar.tintColor = UIColor.backgroundPrimary
    }
}
