
import UIKit

/// Abstraction above UIApplication
protocol ApplicationWindowInsetsProvider {
    
    /// Window insets
    var mainWindowInsets: UIEdgeInsets { get }
}
