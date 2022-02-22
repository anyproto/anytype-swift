import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

final class IntrinsicPopupLayout: FloatingPanelLayout {
    
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .full
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        [
            .full: FloatingPanelIntrinsicLayoutAnchor(absoluteOffset: 0, referenceGuide: .superview)
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
