import UIKit

extension UIApplication: ApplicationWindowInsetsProvider {
    
    @MainActor
    var mainWindowInsets: UIEdgeInsets {
        guard let firstWindow = keyWindow else { return .zero }
        return firstWindow.safeAreaInsets
    }

    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive }
            .flatMap { $0 as? UIWindowScene }?.keyWindow
    }
}
