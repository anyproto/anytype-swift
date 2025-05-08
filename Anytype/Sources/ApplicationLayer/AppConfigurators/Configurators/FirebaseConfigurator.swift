import FirebaseCore
import AnytypeCore
import UserNotifications
import UIKit

final class FirebaseConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        FirebaseApp.configure()
    }
}
