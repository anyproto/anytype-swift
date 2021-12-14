import UIKit

extension UIApplication: ApplicationWindowInsetsProvider {
    var mainWindowInsets: UIEdgeInsets {
        guard let firstWindow = keyWindow else { return .zero }
        return firstWindow.safeAreaInsets
    }

    var keyWindow: UIWindow? {
        windows.filter {$0.isKeyWindow}.first
    }
}
