import Foundation

@MainActor
final class ParticipantDeclineNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRequestDecline
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    @Published var message: String = ""
    
    init(notification: NotificationParticipantRequestDecline) {
        self.notification = notification
        message = Loc.ParticipantRequestDeclineNotification.text(notification.requestDecline.spaceID)
    }
}
