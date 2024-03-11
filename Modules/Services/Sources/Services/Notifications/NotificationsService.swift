import Foundation
import ProtobufMessages

public protocol NotificationsServiceProtocol: AnyObject {
    func list(includeRead: Bool, limit: Int) async throws -> [Notification]
    func reply(ids: [String], actionType: NotificationActionType) async throws
}

final class NotificationsService: NotificationsServiceProtocol {
    
    // MARK: - NotificationsServiceProtocol
    
    public func list(includeRead: Bool, limit: Int) async throws -> [Notification] {
        let response = try await ClientCommands.notificationList(.with {
            $0.includeRead = includeRead
            $0.limit = Int64(limit)
        }).invoke()
        return response.notifications.map { $0.asModel() }
    }
    
    public func reply(ids: [String], actionType: NotificationActionType) async throws {
        try await ClientCommands.notificationReply(.with {
            $0.ids = ids
            $0.actionType = actionType.toMiddleware()
        }).invoke()
    }
}
