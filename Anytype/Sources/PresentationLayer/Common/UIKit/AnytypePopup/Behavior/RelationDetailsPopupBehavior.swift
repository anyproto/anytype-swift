import Foundation
import FloatingPanel
import UIKit

final class RelationDetailsPopupBehavior: FloatingPanelDefaultBehavior {
    
    override func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        guard edge == .top else { return false }
        return true
    }
    
}
