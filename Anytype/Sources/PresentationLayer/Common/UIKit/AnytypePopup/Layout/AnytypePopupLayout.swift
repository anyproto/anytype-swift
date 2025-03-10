import Foundation
import FloatingPanel
import CoreGraphics
import UIKit

@MainActor
open class AnytypePopupLayout: @preconcurrency FloatingPanelLayout {
    
    public let position: FloatingPanelPosition = .bottom
    public let initialState: FloatingPanelState
    public let anchors: [FloatingPanelState : any FloatingPanelLayoutAnchoring]
    
    init(initialState: FloatingPanelState, anchors: [FloatingPanelState : any FloatingPanelLayoutAnchoring]) {
        self.initialState = initialState
        self.anchors = anchors
    }
 
    public func backdropAlpha(for state: FloatingPanelState) -> CGFloat {
        0.3
    }
    
    public func prepareLayout(surfaceView: UIView, in view: UIView) -> [NSLayoutConstraint] {
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

extension AnytypePopupLayout {
    
    static func adjustedPopupHeight(_ height: CGFloat, insetted: Bool, needBottomInset: Bool) -> CGFloat {
        let adjustedHeight = height + AnytypePopup.Constants.grabberHeight
        let bottomInset = needBottomInset ? AnytypePopup.Constants.bottomInset : 0
        return adjustedHeight + bottomInset
    }
    
}
