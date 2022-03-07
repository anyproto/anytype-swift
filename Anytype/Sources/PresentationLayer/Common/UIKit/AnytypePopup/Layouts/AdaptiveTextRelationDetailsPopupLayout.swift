import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class AdaptiveTextRelationDetailsPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    private let layout: UILayoutGuide
    
    init(layout: UILayoutGuide) {
        self.layout = layout
    }
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelAdaptiveLayoutAnchor(absoluteOffset: 0, contentLayout: layout, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.3
    }
    
}
