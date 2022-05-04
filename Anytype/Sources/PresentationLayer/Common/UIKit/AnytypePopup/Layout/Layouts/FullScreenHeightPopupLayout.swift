import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class FullScreenHeightPopupLayout: AnytypePopupLayout {
    
    init() {
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea)
        ]
        
        super.init(initialState: .full, anchors: anchors)
    }
    
}

