import Foundation
import SwiftUI

protocol DashboardAlertsAssemblyProtocol: AnyObject {
    @MainActor
    func makeKeychainRemindView(context: AnalyticsEventsKeychainContext) -> AnyView
    
    @MainActor
    func makeKeychainRemind(context: AnalyticsEventsKeychainContext) -> UIViewController
    
    @MainActor
    func logoutAlert(onBackup: @escaping () -> Void) -> UIViewController
    
    @MainActor
    func accountDeletionAlert() -> UIViewController
    
    @MainActor
    func clearCacheAlert() -> UIViewController
}

final class DashboardAlertsAssembly: DashboardAlertsAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - DashboardAlertsAssemblyProtocol
    
    @MainActor
    func makeKeychainRemindView(context: AnalyticsEventsKeychainContext) -> AnyView {
        let kaychainModel = KeychainPhraseViewModel(
            shownInContext: context,
            seedService: serviceLocator.seedService(),
            localAuthService: serviceLocator.localAuthService()
        )
        let view = DashboardKeychainReminderAlert(keychainViewModel: kaychainModel)
        return view.eraseToAnyView()
    }
    
    @MainActor
    func makeKeychainRemind(context: AnalyticsEventsKeychainContext) -> UIViewController {
        return popup(view: makeKeychainRemindView(context: context))
    }
    
    @MainActor
    func logoutAlert(onBackup: @escaping () -> Void) -> UIViewController {
        let model = DashboardLogoutAlertModel(
            authService: serviceLocator.authService(),
            applicationStateService: serviceLocator.applicationStateService(),
            onBackup: onBackup
        )
        let view = DashboardLogoutAlert(model: model)
        return popup(view: view)
    }
    
    @MainActor
    func accountDeletionAlert() -> UIViewController {
        let model = DashboardAccountDeletionAlertModel(
            authService: serviceLocator.authService(),
            applicationStateService: serviceLocator.applicationStateService()
        )
        let view = DashboardAccountDeletionAlert(model: model)
        return popup(view: view)
    }
    
    @MainActor
    func clearCacheAlert() -> UIViewController {
        let model = DashboardClearCacheAlertModel(
            alertOpener: uiHelpersDI.alertOpener(),
            fileActionService: serviceLocator.fileService()
        )
        let view = DashboardClearCacheAlert(model: model)
        return popup(view: view)
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
