import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class RelationOptionsPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea)
        ]
    }
    
    func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.3
    }
    
    func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
        if UIDevice.isPad {
            return [
                surfaceView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
                surfaceView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor)
            ]
        } else {
            return [
                surfaceView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                surfaceView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        }
    }
    
}
