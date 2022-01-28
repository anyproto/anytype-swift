import Foundation
import FloatingPanel
import CoreGraphics

final class FixedHeightPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    let height: CGFloat
    
    init(height: CGFloat) {
        self.height = height + RelationDetailsViewPopup.grabberHeight
    }
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelLayoutAnchor(absoluteInset: height, edge: .bottom, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.3
    }
    
}
