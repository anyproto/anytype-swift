import Foundation
import SwiftEntryKit


final class AlertOpener: AlertOpenerProtocol {
    
    private let navigationContext: NavigationContextProtocol
    
    nonisolated init(navigationContext: NavigationContextProtocol) {
        self.navigationContext = navigationContext
    }
    
    // MARK: - AlertOpenerProtocol
    
    func showTopAlert(message: String) {
        let view = TopAlertView(title: message)

        var attributes = EKAttributes()
        attributes.positionConstraints = .float
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: false)
        attributes.windowLevel = .statusBar
        attributes.positionConstraints.size = .init(width: .intrinsic, height: .intrinsic)
        attributes.position = .top
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.2, radius: 5, offset: .zero))
        attributes.precedence = .enqueue(priority: .normal)
        
        SwiftEntryKit.display(entry: view, using: attributes)
    }
    
    func showLoadingAlert(message: String) -> AnytypeDismiss {
        let view = DashboardLoadingAlert(text: message)
        
        let popup = AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
        
        return navigationContext.present(popup)
    }
    
    func showFloatAlert(model: BottomAlertLegacy) -> AnytypeDismiss {
        let view = FloaterAlertView(bottomAlert: model)
        
        let popup = AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
        
        return navigationContext.present(popup)
    }
}
