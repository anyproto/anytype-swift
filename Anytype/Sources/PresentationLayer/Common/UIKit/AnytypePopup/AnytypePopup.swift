import Foundation
import FloatingPanel
import UIKit
import SwiftUI
import Combine
import AnytypeCore

// TODO: Delete it
// Use Native SwiftUI navigation
@MainActor
class AnytypePopup: FloatingPanelController {

    struct Configuration {
        let isGrabberVisible: Bool
        let dismissOnBackdropView: Bool
        let skipThroughGestures: Bool

        init(isGrabberVisible: Bool, dismissOnBackdropView: Bool, skipThroughGestures: Bool = false) {
            self.isGrabberVisible = isGrabberVisible
            self.dismissOnBackdropView = dismissOnBackdropView
            self.skipThroughGestures = skipThroughGestures
        }
    }
        
    private let viewModel: any AnytypePopupViewModelProtocol
    private let floatingPanelStyle: Bool
    private let configuration: Configuration
    private let onDismiss: (() -> Void)?

    // MARK: - Initializers
    
    init(viewModel: some AnytypePopupViewModelProtocol,
         floatingPanelStyle: Bool = false,
         configuration: Configuration = Constants.defaultConifguration,
         onDismiss: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.floatingPanelStyle = floatingPanelStyle
        self.configuration = configuration
        self.onDismiss = onDismiss

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

    convenience init<Content: UIView>(contentView: Content,
                                      popupLayout: AnytypePopupLayoutType = .alert(height: 0),
                                      floatingPanelStyle: Bool = false,
                                      configuration: Configuration = Constants.defaultConifguration,
                                      showKeyboard: Bool = false,
                                      onDismiss: (() -> Void)? = nil) {
        let viewModel = AnytypeAlertViewModel(
            contentView: contentView,
            keyboardListener: .init(),
            popupLayout: popupLayout,
            showKeyboard: showKeyboard
        )
        self.init(viewModel: viewModel, floatingPanelStyle: floatingPanelStyle, configuration: configuration, onDismiss: onDismiss)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.willAppear()
    }
}

// MARK: - RelationDetailsViewModelDelegate

@MainActor
extension AnytypePopup: AnytypePopupProxy {
    func updateBottomInset() {
        updateSurfaceViewMargins()
        updateLayout(true)
    }

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

extension AnytypePopup: @preconcurrency FloatingPanelControllerDelegate {
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> any FloatingPanelLayout {
        viewModel.popupLayout.layout
    }
    
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> any FloatingPanelLayout {
        viewModel.popupLayout.layout
    }

    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if let contentHeight = fpc.surfaceView.contentView?.bounds.height,
           contentHeight / 2 < surfaceOffset {
            return true
        }

        guard let threshold = fpc.behavior.removalInteractionVelocityThreshold else {
            return false
        }

        switch fpc.layout.position {
        case .top:
            return (velocity.dy <= -threshold)
        case .left:
            return (velocity.dx <= -threshold)
        case .bottom:
            return (velocity.dy >= threshold)
        case .right:
            return (velocity.dx >= threshold)
        }
    }

    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        onDismiss?()
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
        contentView.view.backgroundColor = .Background.secondary

        set(contentViewController: contentView)
    }
    
    func setupGestures() {
        isRemovalInteractionEnabled = true

        if configuration.skipThroughGestures {
            backdropView.isHidden = true
        } else {
            backdropView.dismissalTapGestureRecognizer.isEnabled = configuration.dismissOnBackdropView
        }
    }
    
    func setupSurfaceView() {
        surfaceView.appearance = makeAppearance()
        
        surfaceView.grabberHandlePadding = 6.0
        surfaceView.grabberHandleSize = CGSize(width: 48.0, height: 4.0)
        surfaceView.grabberHandle.backgroundColor = .Shape.primary
        surfaceView.grabberHandle.isHidden = !configuration.isGrabberVisible

        surfaceView.contentPadding = UIEdgeInsets(
            top: configuration.isGrabberVisible ? Constants.grabberHeight : 0,
            left: 0,
            bottom: 0,
            right: 0
        )

        updateSurfaceViewMargins()

        if FeatureFlags.rainbowViews {
            surfaceView.backgroundColor = .red
            surfaceView.grabberHandle.backgroundColor = .yellow
            surfaceView.containerView.backgroundColor = .green
        }
    }

    func updateSurfaceViewMargins() {
        if floatingPanelStyle {
            let horizontalInset = UIDevice.isPad ? 0.0 : 8.0

            switch viewModel.popupLayout {
            case .alert(let height):
                let safeBottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                let bottomInset = max(
                    height + Constants.bottomAlertInset,
                    Constants.bottomAlertMinimumInset + safeBottomInset
                )
                surfaceView.containerMargins = UIEdgeInsets(
                    top: 0,
                    left: horizontalInset,
                    bottom: bottomInset,
                    right: horizontalInset
                )
            default:
                surfaceView.containerMargins = UIEdgeInsets(top: 0, left: horizontalInset, bottom: Constants.bottomInset, right: horizontalInset)
            }
        }
    }
    
    func makeAppearance() -> SurfaceAppearance {
        let appearance = SurfaceAppearance()
        appearance.backgroundColor = .Background.secondary
        appearance.cornerRadius = 16.0
        appearance.cornerCurve = .continuous


        appearance.shadows = [makeShadow()]
        
        return appearance
    }
    
    func makeShadow() -> SurfaceAppearance.Shadow {
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.Shadow.primary
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
        static let bottomAlertInset: CGFloat = 16
        static let bottomAlertMinimumInset: CGFloat = 60
        static let defaultConifguration: Configuration = .init(isGrabberVisible: true, dismissOnBackdropView: true)
    }
    
}
