import Foundation
import UIKit

@MainActor
@Observable
final class DisabledPushNotificationsAlertViewModel {

    var dismiss = false
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenAllowPushType(.subsequent)
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        dismiss.toggle()
        AnytypeAnalytics.instance().logClickAllowPushType(.settings)
    }
    
    func skip() {
        dismiss.toggle()
    }
}
