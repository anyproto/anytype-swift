import SwiftUI

struct DashboardClearCacheAlert: View {
    @EnvironmentObject private var homeModel: HomeViewModel
    @EnvironmentObject private var settingsModel: SettingsViewModel
    
    var body: some View {
        FloaterAlertView(
            title: Loc.clearCache,
            description: Loc.clearCacheDescription,
            leftButtonData: StandardButtonModel(text: Loc.cancel, style: .secondary) {
                settingsModel.clearCacheAlert = false
            },
            rightButtonData: StandardButtonModel(text: "Clear", style: .destructive) {
                homeModel.loadingAlertData = .init(text: Loc.removingCache, showAlert: true)
                
                settingsModel.clearCache { clearCacheSuccessful in
                    homeModel.loadingAlertData = .empty
                    
                    if clearCacheSuccessful {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        settingsModel.clearCacheAlert = false
                        settingsModel.account = false
                        homeModel.snackBarData = .init(text: "Cache sucessfully cleared", showSnackBar: true)
                    } else {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        homeModel.snackBarData = .init(text: "Error, try again later", showSnackBar: true)
                    }
                }
            }
        )
    }
}
