import Foundation
import SwiftEntryKit


final class AlertOpener: AlertOpenerProtocol {
    
    private let navigationContext: NavigationContextProtocol
    
    nonisolated init(navigationContext: NavigationContextProtocol) {
        self.navigationContext = navigationContext
    }
    
    // MARK: - AlertOpenerProtocol
    
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
