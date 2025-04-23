import UIKit
import SwiftUI

// MARK: - Constraints

public extension UIView {
    
    /// Pins all edges of view to a given view with zero insets.
    ///
    /// This function adds top, bottom, leading and trailinig constraints with zero insets.
    ///
    /// - Parameter view: The view to pin edges.
    func pinAllEdges(to view: UIView) {
        pinAllEdges(to: view, insets: .zero)
    }
    
    /// Pins all edges of view to a given view with specified insets.
    ///
    /// This function adds top, bottom, leading and trailinig constraints with specified insets.
    ///
    /// - Parameters:
    ///   - view: The view to pin edges.
    ///   - insets: The insets for all edges.
    func pinAllEdges(to view: UIView, insets: UIEdgeInsets) {
        layoutUsing.anchors {
            $0.pin(to: view, insets: insets)
        }
    }
    
}
