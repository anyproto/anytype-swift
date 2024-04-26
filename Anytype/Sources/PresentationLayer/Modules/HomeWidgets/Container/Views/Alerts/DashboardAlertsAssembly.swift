import Foundation
import SwiftUI

protocol DashboardAlertsAssemblyProtocol: AnyObject {    
    @MainActor
    func logoutAlert(onBackup: @escaping () -> Void, onLogout: @escaping () -> Void) -> UIViewController
    
    @MainActor
    func accountDeletionAlert() -> UIViewController
}

final class DashboardAlertsAssembly: DashboardAlertsAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - DashboardAlertsAssemblyProtocol
    
    @MainActor
    func logoutAlert(onBackup: @escaping () -> Void, onLogout: @escaping () -> Void) -> UIViewController {
        let model = DashboardLogoutAlertModel(
            onBackup: onBackup, 
            onLogout: onLogout
        )
        let view = DashboardLogoutAlert(model: model)
        return popup(view: view)
    }
    
    @MainActor
    func accountDeletionAlert() -> UIViewController {
        return popup(view: DashboardAccountDeletionAlert())
    }
    
    // MARK: - Private
    
    private func popup<Content: View>(view: Content) -> UIViewController {
        return AnytypePopup(
            contentView: view,
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
    }
}
