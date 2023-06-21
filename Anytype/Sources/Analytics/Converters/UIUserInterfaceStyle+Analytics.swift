import UIKit

extension UIUserInterfaceStyle {
    var analyticsId: String {
        switch self {
        case .unspecified:
            return "system"
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "system"
        }
    }
}
