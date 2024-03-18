import Foundation

@MainActor
final class ParticipantApproveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRequestApproved
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    @Published var message: String = ""
    @Published var icon: Icon?
    
    init(notification: NotificationParticipantRequestApproved) {
        self.notification = notification
        let spaceView = workspaceStorage.spaceView(spaceId: notification.requestApprove.spaceID)
        icon = spaceView?.iconImage
        message = Loc.ParticipantRequestApprovedNotification.text(spaceView?.name ?? "", notification.requestApprove.permissions.grandTitle)
    }
}
