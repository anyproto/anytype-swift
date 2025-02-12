import FirebaseCore
import AnytypeCore
import UserNotifications
import UIKit

final class FirebaseConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        guard FeatureFlags.firebasePushMessages else { return }
        
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
