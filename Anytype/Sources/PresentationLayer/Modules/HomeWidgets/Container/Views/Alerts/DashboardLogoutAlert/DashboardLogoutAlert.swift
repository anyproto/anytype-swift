import SwiftUI

struct DashboardLogoutAlert: View {
    @ObservedObject var model: DashboardLogoutAlertModel
    
    var body: some View {
        FloaterAlertView(
            title: Loc.Keychain.haveYouBackedUpYourRecoveryPhrase,
            description: Loc.Keychain.Key.description,
            leftButtonData: StandardButtonModel(text: Loc.backUpPhrase, disabled: model.isLogoutInProgress, style: .secondaryLarge) {
                model.onBackupTap()
            },
            rightButtonData: StandardButtonModel(text: Loc.logOut, inProgress: model.isLogoutInProgress, style: .warningLarge) {
                model.onLogoutTap()
            }
        )
    }
}
