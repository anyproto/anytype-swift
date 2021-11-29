import SwiftUI

struct DashboardClearCacheAlert: View {
    @EnvironmentObject private var homeModel: HomeViewModel
    @EnvironmentObject private var settingsModel: SettingsViewModel
    
    var body: some View {
        FloaterAlertView(
            title: "Clear cache".localized,
            description: "Clear cache description".localized,
            leftButtonData: StandardButtonData(text: "Cancel".localized, style: .secondary) {
                settingsModel.clearCacheAlert = false
            },
            rightButtonData: StandardButtonData(text: "Clear", style: .destructive) {
                settingsModel.loadingAlert = .init(text: "Removing cache", showAlert: true)
                
                settingsModel.clearCache { clearCacheSuccessful in
                    settingsModel.loadingAlert = .empty
                    
                    if clearCacheSuccessful {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        settingsModel.clearCacheAlert = false
                        settingsModel.other = false
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
