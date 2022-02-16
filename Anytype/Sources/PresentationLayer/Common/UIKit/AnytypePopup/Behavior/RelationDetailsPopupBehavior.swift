import Foundation
import FloatingPanel
import UIKit

final class RelationDetailsPopupBehavior: FloatingPanelDefaultBehavior {
    
    override func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        true
    }
    
}
