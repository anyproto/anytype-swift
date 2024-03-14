import Foundation

@MainActor
final class PermissionChangeNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantPermissionsChange
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    @Published var message: String = ""
    @Published var icon: Icon?
    
    init(notification: NotificationParticipantPermissionsChange) {
        self.notification = notification
        let spaceView = workspaceStorage.spaceView(spaceId: notification.permissionChange.spaceID)
        icon = spaceView?.iconImage
        message = Loc.PermissionChangeNotification.text(notification.permissionChange.permissions.grandTitle, spaceView?.name ?? "")
    }
}
