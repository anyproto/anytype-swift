import Foundation
import FloatingPanel
import UIKit

#warning("TODO R: init with ViewModel + subscribe for content update in order to update floatingpanel layout")
final class RelationDetailsViewPopup: FloatingPanelController {
    
    var keyboardPopupLayoutUpdater: KeyboardPopupLayoutUpdater?
    
    // MARK: - Initializers
    
    init(contentViewController: UIViewController) {
        super.init(delegate: nil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
}

// MARK: - Private extension

private extension RelationDetailsViewPopup {
    
    func setup() {
        setupGestures()
        setupSurfaceView()
        
        contentMode = .static
        
        set(contentViewController: contentViewController)
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
