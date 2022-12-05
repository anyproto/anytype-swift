import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class ConstantHeightPopupLayout: AnytypePopupLayout {
    
    init(height: CGFloat, floatingPanelStyle: Bool, needBottomInset: Bool) {
        let adjustedHeight = AnytypePopupLayout.adjustedPopupHeight(
            height,
            insetted: floatingPanelStyle,
            needBottomInset: needBottomInset
        )
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: adjustedHeight, edge: .bottom, referenceGuide: .superview)
        ]

        super.init(initialState: .full, anchors: anchors)
    }
    
}
