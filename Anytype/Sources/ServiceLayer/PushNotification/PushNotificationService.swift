import Foundation
import UserNotifications
import UIKit

protocol PushNotificationServiceProtocol: AnyObject {
    func setToken(data: Data)
    func token() -> String?
    func requestAccess()
}

final class PushNotificationService: PushNotificationServiceProtocol {
    
    private var tokenString: String?
    
    func setToken(data: Data) {
        tokenString = data.map { String(format: "%02x", $0) }.joined()
    }
    
    func token() -> String? {
        return tokenString
    }
    
    func requestAccess() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
