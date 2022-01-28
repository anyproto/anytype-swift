import Foundation
import FloatingPanel
import UIKit
import SwiftUI
import Combine
import AnytypeCore

final class RelationDetailsViewPopup: FloatingPanelController {
        
    private var viewModel: RelationDetailsViewModelProtocol
    
    // MARK: - Initializers
    
    init(viewModel: RelationDetailsViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(delegate: nil)
        
        self.viewModel.delegate = self
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - RelationDetailsViewModelDelegate

extension RelationDetailsViewPopup: RelationDetailsViewModelDelegate {
    
    func didAskInvalidateLayout(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.invalidateLayout()
            }
        } else {
            self.invalidateLayout()
        }
    }
    
    func didAskToClose() {
        hide(animated: true) {
            self.removePanelFromParent(animated: false, completion: nil)
        }
    }

    
}

// MARK: - FloatingPanelControllerDelegate

extension RelationDetailsViewPopup: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        viewModel.floatingPanelLayout
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        viewModel.floatingPanelLayout
    }
    
}

// MARK: - Private extension

private extension RelationDetailsViewPopup {
    
    func setup() {
        setupGestures()
        setupSurfaceView()
        
        behavior = RelationDetailsPopupBehavior()
        contentMode = .static
        delegate = self
        
        set(contentViewController: viewModel.makeViewController())
    }
    
    func setupGestures() {
        isRemovalInteractionEnabled = true
        backdropView.dismissalTapGestureRecognizer.isEnabled = true
    }
    
    func setupSurfaceView() {
        surfaceView.appearance = makeAppearance()
        
        surfaceView.grabberHandlePadding = 6.0
        surfaceView.grabberHandleSize = CGSize(width: 48.0, height: 4.0)
        surfaceView.grabberHandle.backgroundColor = .strokePrimary
        
        surfaceView.contentPadding = UIEdgeInsets(top: RelationDetailsViewPopup.grabberHeight, left: 0, bottom: 0, right: 0)

        if FeatureFlags.rainbowViews {
            surfaceView.backgroundColor = .red
        }
    }
    
    func makeAppearance() -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        appearance.cornerCurve = .continuous
        
        appearance.shadows = [makeShadow()]
        
        return appearance
    }
    
    func makeShadow() -> SurfaceAppearance.Shadow {
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.shadowPrimary
        shadow.offset = CGSize(width: 0, height: 0)
        shadow.radius = 40
        shadow.opacity = 1
        
        return shadow
    }
    
}

extension RelationDetailsViewPopup {
    
    static let grabberHeight: CGFloat = 16
    
}
