import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class AdaptiveTextPropertyDetailsPopupLayout: AnytypePopupLayout {
    
    init(layout: UILayoutGuide) {
        let anchors: [FloatingPanelState : any FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelAdaptiveLayoutAnchor(absoluteOffset: 0, contentLayout: layout, referenceGuide: .safeArea)
        ]
        super.init(initialState: .full, anchors: anchors)
    }
    
}
