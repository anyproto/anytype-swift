import Foundation

@MainActor
@Observable
final class ParticipantApproveNotificationViewModel {

    private let notification: NotificationParticipantRequestApproved

    var message: String = ""
    
    init(notification: NotificationParticipantRequestApproved) {
        self.notification = notification
        message = Loc.ParticipantRequestApprovedNotification.text(
            notification.requestApprove.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces),
            notification.requestApprove.permissions.grandTitle
        )
    }
}
