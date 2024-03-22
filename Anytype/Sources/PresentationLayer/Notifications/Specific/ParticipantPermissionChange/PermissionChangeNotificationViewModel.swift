import Foundation

@MainActor
final class PermissionChangeNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantPermissionsChange
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    @Published var message: String = ""
    
    init(notification: NotificationParticipantPermissionsChange) {
        self.notification = notification
        message = Loc.PermissionChangeNotification.text(notification.permissionChange.permissions.grandTitle, notification.permissionChange.spaceName)
    }
}
