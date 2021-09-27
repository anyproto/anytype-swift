
import UIKit

extension UIApplication: ApplicationWindowInsetsProvider {
    
    var mainWindowInsets: UIEdgeInsets {
        guard let firstWindow = keyWindow else { return .zero }
        return firstWindow.safeAreaInsets
    }
    
    var keyWindow: UIWindow? {
            // Get connected scenes
            return connectedScenes
                // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
                // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
                // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
                // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        }
}
