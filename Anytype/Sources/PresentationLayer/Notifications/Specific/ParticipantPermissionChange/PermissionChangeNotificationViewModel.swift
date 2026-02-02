import Foundation

@MainActor
@Observable
final class PermissionChangeNotificationViewModel {

    private let notification: NotificationParticipantPermissionsChange
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol

    var message: String = ""
    
    init(notification: NotificationParticipantPermissionsChange) {
        self.notification = notification
        message = Loc.PermissionChangeNotification.text(
            notification.permissionChange.permissions.grandTitle,
            notification.permissionChange.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces)
        )
    }
}
