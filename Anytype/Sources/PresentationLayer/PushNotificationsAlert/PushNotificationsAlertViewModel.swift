import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationsAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    
    func enablePushesTap() {
        dismiss.toggle()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func laterTap() {
        dismiss.toggle()
    }
}
