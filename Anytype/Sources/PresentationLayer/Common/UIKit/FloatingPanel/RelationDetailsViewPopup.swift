import Foundation
import FloatingPanel
import UIKit
import SwiftUI
import Combine

#warning("TODO R: init with ViewModel + subscribe for content update in order to update floatingpanel layout")
final class RelationDetailsViewPopup: FloatingPanelController {
    
    var keyboardPopupLayoutUpdater: KeyboardPopupLayoutUpdater?
    
    private let viewModel: RelationDetailsViewModelProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(viewModel: RelationDetailsViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(delegate: nil)
        
        setup()
        
        set(contentViewController: UIHostingController(rootView: viewModel.makeView()))
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private extension

private extension RelationDetailsViewPopup {
    
    func updatePopupLayout(viewHeight: CGFloat) {
        layout = FixedHeightPopupLayout(height: viewHeight + Self.grabberHeight)
        invalidateLayout()
    }
    
}

private extension RelationDetailsViewPopup {
    
    func setup() {
        setupFloatingPanelController()
        
        viewModel.heightPublisher
            .receiveOnMain()
            .sink { [weak self] height in
                self?.updatePopupLayout(viewHeight: height)
            }
            .store(in: &cancellables)
    }
    
    func setupFloatingPanelController() {
        setupGestures()
        setupSurfaceView()
        
        behavior = RelationDetailsViewPopupBehavior()
        contentMode = .static
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

        #if DEBUG
        surfaceView.backgroundColor = .red
        #endif
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
