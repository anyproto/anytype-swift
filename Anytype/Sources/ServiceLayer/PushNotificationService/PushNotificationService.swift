import Foundation

protocol PushNotificationServiceProtocol: AnyObject {
    func setToken(data: Data)
    func token() -> String?
}

final class PushNotificationService: PushNotificationServiceProtocol {

    private var tokenString: String?

    func setToken(data: Data) {
        tokenString = data.map { String(format: "%02x", $0) }.joined()
    }

    func token() -> String? {
        return tokenString
    }
}
