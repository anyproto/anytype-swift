import Foundation

@MainActor
final class ParticipantApproveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRequestApproved
    
    @Published var message: String = ""
    
    init(notification: NotificationParticipantRequestApproved) {
        self.notification = notification
        message = Loc.ParticipantRequestApprovedNotification.text(
            notification.requestApprove.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces),
            notification.requestApprove.permissions.grandTitle
        )
    }
}
