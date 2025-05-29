import Foundation
import UIKit

@MainActor
final class DisabledPushNotificationsAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    
    @Injected(\.pushNotificationsAlertHandler)
    private var pushNotificationsAlertHandler: any PushNotificationsAlertHandlerProtocol
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        dismiss.toggle()
    }
    
    func skip() {
        dismiss.toggle()
    }
}
