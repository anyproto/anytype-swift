import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class IntrinsicPopupLayout: AnytypePopupLayout {
    
    init() {
        let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelIntrinsicLayoutAnchor(absoluteOffset: 0, referenceGuide: .superview)
        ]
        
        super.init(initialState: .full, anchors: anchors)
    }
    
}
