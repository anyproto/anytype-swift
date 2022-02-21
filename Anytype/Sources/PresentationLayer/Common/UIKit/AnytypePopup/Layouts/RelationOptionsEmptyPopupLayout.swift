import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class RelationOptionsEmptyPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .half
    
    let height: CGFloat
    
    init(height: CGFloat) {
        self.height = height + AnytypePopup.grabberHeight
    }
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .half: FloatingPanelLayoutAnchor(absoluteInset: height, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: height, edge: .bottom, referenceGuide: .safeArea)
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
