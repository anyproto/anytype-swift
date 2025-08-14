import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class PropertyOptionsPopupLayout: AnytypePopupLayout {
    
    init() {
        let anchors: [FloatingPanelState: any FloatingPanelLayoutAnchoring] = [
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea)
        ]
        
        super.init(initialState: .half, anchors: anchors)
        
    }
    
}
