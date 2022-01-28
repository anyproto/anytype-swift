import Foundation
import FloatingPanel
import UIKit
import SwiftUI
import Combine
import AnytypeCore

final class RelationDetailsViewPopup: FloatingPanelController {
        
    private var viewModel: RelationDetailsViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(viewModel: RelationDetailsViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(delegate: nil)
        
        self.viewModel.closePopupAction = { [weak self] in
            self?.closePopup()
        }
        
        setup()
        
        set(contentViewController: viewModel.makeViewController())
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private extension

private extension RelationDetailsViewPopup {
    
    func updateLayout(_ layout: FloatingPanelLayout) {
        self.layout = layout//FixedHeightPopupLayout(height: viewHeight + Self.grabberHeight)
        UIView.animate(withDuration: 0.3) {
            self.invalidateLayout()
        }
    }
    
    func closePopup() {
        hide(animated: true) {
            self.removePanelFromParent(animated: false, completion: nil)
        }
    }
    
}

extension RelationDetailsViewPopup: FloatingPanelControllerDelegate {
    
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if self.isAttracting == false {
            let loc = self.surfaceLocation
            let minY = self.surfaceLocation(for: .full).y
            let maxY = self.surfaceLocation(for: .tip).y
            self.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, minY), maxY))
        }
    }
    
}

private extension RelationDetailsViewPopup {
    
    func setup() {
        setupFloatingPanelController()
        
        viewModel.layoutPublisher
            .receiveOnMain()
            .sink { [weak self] layout in
                self?.updateLayout(layout)
            }
            .store(in: &cancellables)
    }
    
    func setupFloatingPanelController() {
        setupGestures()
        setupSurfaceView()
        
        behavior = FloatingPanelDefaultBehavior()
        contentMode = .static
        delegate = self
    }
    
    func setupGestures() {
        isRemovalInteractionEnabled = true
        backdropView.dismissalTapGestureRecognizer.isEnabled = true
    }
    
    func setupSurfaceView() {
        surfaceView.appearance = makeAppearance()
        
        surfaceView.grabberHandlePadding = 6.0
        surfaceView.grabberHandleSize = CGSize(width: 48.0, height: 4.0)
        surfaceView.grabberHandle.backgroundColor = .stroke
        
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
        shadow.color = UIColor.grayscale90.withAlphaComponent(0.25)
        shadow.offset = CGSize(width: 0, height: 0)
        shadow.radius = 40
        shadow.opacity = 1
        
        return shadow
    }
    
}

extension RelationDetailsViewPopup {
    
    static let grabberHeight: CGFloat = 16
    
}
