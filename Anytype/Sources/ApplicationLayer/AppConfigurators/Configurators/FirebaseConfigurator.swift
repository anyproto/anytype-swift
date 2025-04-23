import FirebaseCore
import AnytypeCore
import UserNotifications
import UIKit

final class FirebaseConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        guard FeatureFlags.enablePushMessages else { return }
        
        FirebaseApp.configure()
    }
}
