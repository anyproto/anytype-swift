
import UIKit

extension UIApplication: ApplicationWindowInsetsProvider {
    
    var mainWindowInsets: UIEdgeInsets {
        guard let firstWindow = windows.first else { return .zero }
        return firstWindow.safeAreaInsets
    }
}
