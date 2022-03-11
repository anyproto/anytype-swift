import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class AdaptiveTextRelationDetailsPopupLayout: AnytypePopupLayout {
    
    init(layout: UILayoutGuide) {
        let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelAdaptiveLayoutAnchor(absoluteOffset: 0, contentLayout: layout, referenceGuide: .safeArea)
        ]
        super.init(initialState: .full, anchors: anchors)
    }
    
}
