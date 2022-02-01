import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class IntrinsicTextRelationDetailsPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelIntrinsicLayoutAnchor(absoluteOffset: 0, referenceGuide: .superview)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.3
    }
    
}
