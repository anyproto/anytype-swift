
import UIKit

/// Abstraction above UIApplication
protocol ApplicationWindowInsetsProvider {
    
    /// Window insets
    @MainActor
    var mainWindowInsets: UIEdgeInsets { get }
}
