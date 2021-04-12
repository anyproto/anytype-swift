
import UIKit

/// Abstraction above UIApplication
protocol ApplicationWindowInsetsProviderProtocol {
    
    /// Window insets
    var mainWindowInsets: UIEdgeInsets { get }
}
