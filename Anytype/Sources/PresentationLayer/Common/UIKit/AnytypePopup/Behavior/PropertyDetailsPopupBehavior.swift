import Foundation
import FloatingPanel
import UIKit

final class PropertyDetailsPopupBehavior: FloatingPanelBehavior {
    
    public let springDecelerationRate: CGFloat = UIScrollView.DecelerationRate.fast.rawValue + 0.001

    public let springResponseTime: CGFloat = 0.4

    public let momentumProjectionRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue
    
    public let removalInteractionVelocityThreshold: CGFloat = 2.0
    
    public func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        guard edge == .top else { return false }
        return true
    }

    public func redirectionalProgress(_ fpc: FloatingPanelController, from: FloatingPanelState, to: FloatingPanelState) -> CGFloat {
        return 0.5
    }
    
    
}
