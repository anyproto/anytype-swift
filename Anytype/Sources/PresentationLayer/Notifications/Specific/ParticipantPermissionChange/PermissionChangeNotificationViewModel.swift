import Foundation

@MainActor
final class PermissionChangeNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantPermissionsChange
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    
    @Published var message: String = ""
    
    init(notification: NotificationParticipantPermissionsChange) {
        self.notification = notification
        message = Loc.PermissionChangeNotification.text(
            notification.permissionChange.permissions.grandTitle,
            notification.permissionChange.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
        )
    }
}
