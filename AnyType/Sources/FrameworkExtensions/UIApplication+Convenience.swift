
import UIKit

extension UIApplication {
    
    /// Get safe area insets for application window
    func keyWindowSafeAreaInsets() -> UIEdgeInsets {
        guard let firstWindow = windows.first else { return .zero }
        return firstWindow.safeAreaInsets
    }
}

extension UIApplication: ApplicationWindowInsetsProviderProtocol {
    
    var mainWindowInsets: UIEdgeInsets {
        keyWindowSafeAreaInsets()
    }
}
