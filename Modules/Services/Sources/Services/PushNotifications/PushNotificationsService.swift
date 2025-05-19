import Foundation
import ProtobufMessages

public protocol PushNotificationsServiceProtocol: AnyObject, Sendable {
    func pushNotificationRegisterToken(token: String) async throws
}

final class PushNotificationsService: PushNotificationsServiceProtocol {
    
    // MARK: - PushNotificationsServiceProtocol
    
    public func pushNotificationRegisterToken(token: String) async throws {
        try await ClientCommands.pushNotificationRegisterToken(.with {
            $0.token = token
            $0.platform = .ios
        }).invoke()
    }
}
