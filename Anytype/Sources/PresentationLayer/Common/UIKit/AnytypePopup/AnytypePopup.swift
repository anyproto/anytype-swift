import Foundation
import FloatingPanel
import UIKit
import SwiftUI
import Combine
import AnytypeCore

final class AnytypePopup: FloatingPanelController {

    struct Configuration {
        let isGrabberVisible: Bool
        let dismissOnBackdropView: Bool
    }
        
    private let viewModel: AnytypePopupViewModelProtocol
    private let floatingPanelStyle: Bool
    private let configuration: Configuration
    
    // MARK: - Initializers
    
    init(viewModel: AnytypePopupViewModelProtocol,
         floatingPanelStyle: Bool = false,
         configuration: Configuration = Constants.defaultConifguration) {
        self.viewModel = viewModel
        self.floatingPanelStyle = floatingPanelStyle
        self.configuration = configuration
        
        super.init(delegate: nil)
        
        viewModel.onPopupInstall(self)
        
        setup()
    }

    convenience init<Content: View>(contentView: Content,
                                    popupLayout: AnytypePopupLayoutType = .constantHeight(height: 0, floatingPanelStyle: true),
                                    floatingPanelStyle: Bool = false,
                                    configuration: Configuration = Constants.defaultConifguration) {
        let popupView = AnytypePopupViewModel(contentView: contentView, popupLayout: popupLayout)
        self.init(viewModel: popupView, floatingPanelStyle: floatingPanelStyle, configuration: configuration)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - RelationDetailsViewModelDelegate

extension AnytypePopup: AnytypePopupProxy {
    
    func updateLayout(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.invalidateLayout()
            }
        } else {
            self.invalidateLayout()
        }
    }
    
    func close() {
        hide(animated: true) {
            self.dismiss(animated: false)
        }
    }
    
}

// MARK: - FloatingPanelControllerDelegate

extension AnytypePopup: FloatingPanelControllerDelegate {
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        viewModel.popupLayout.layout
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        viewModel.popupLayout.layout
    }
    
}

// MARK: - Private extension

private extension AnytypePopup {
    
    func setup() {
        setupGestures()
        setupSurfaceView()
        
        behavior = RelationDetailsPopupBehavior()
        contentMode = .static
        delegate = self
        
        let contentView = viewModel.makeContentView()
        contentView.view.backgroundColor = .backgroundSecondary
        
        set(contentViewController: contentView)
    }
    
    func setupGestures() {
        isRemovalInteractionEnabled = configuration.dismissOnBackdropView
        backdropView.dismissalTapGestureRecognizer.isEnabled = configuration.dismissOnBackdropView
    }
    
    func setupSurfaceView() {
        surfaceView.appearance = makeAppearance()
        
        surfaceView.grabberHandlePadding = 6.0
        surfaceView.grabberHandleSize = CGSize(width: 48.0, height: 4.0)
        surfaceView.grabberHandle.backgroundColor = .strokePrimary
        surfaceView.grabberHandle.isHidden = !configuration.isGrabberVisible

        surfaceView.contentPadding = UIEdgeInsets(
            top: configuration.isGrabberVisible ? Constants.grabberHeight : 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        if floatingPanelStyle {
            let horizontalInset = UIDevice.isPad ? 0.0 : 8.0
            surfaceView.containerMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: Constants.bottomInset, right: horizontalInset)
        }

        if FeatureFlags.rainbowViews {
            surfaceView.backgroundColor = .red
            surfaceView.grabberHandle.backgroundColor = .yellow
            surfaceView.containerView.backgroundColor = .green
        }
    }
    
    func makeAppearance() -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        appearance.backgroundColor = .backgroundSecondary
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

extension AnytypePopup {
    
    enum Constants {
        static let grabberHeight: CGFloat = 16
        static let bottomInset: CGFloat = 44
        static let defaultConifguration: Configuration = .init(isGrabberVisible: true, dismissOnBackdropView: true)
    }
    
}
