import Foundation
import UIKit

@MainActor
final class DisabledPushNotificationsAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        dismiss.toggle()
    }
    
    func skip() {
        dismiss.toggle()
    }
}
