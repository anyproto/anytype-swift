import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class RelationOptionsEmptyPopupLayout: AnytypePopupLayout {
    
    init(height: CGFloat) {
        let adjustedHeight = height + AnytypePopup.grabberHeight
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .half: FloatingPanelLayoutAnchor(absoluteInset: adjustedHeight, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: adjustedHeight, edge: .bottom, referenceGuide: .safeArea)
        ]
        
        super.init(initialState: .half, anchors: anchors)
    }
    
}
