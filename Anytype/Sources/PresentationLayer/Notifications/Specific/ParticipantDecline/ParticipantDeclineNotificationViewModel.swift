import Foundation

@MainActor
@Observable
final class ParticipantDeclineNotificationViewModel {

    private let notification: NotificationParticipantRequestDecline

    var message: String = ""
    
    init(notification: NotificationParticipantRequestDecline) {
        self.notification = notification
        message = Loc.ParticipantRequestDeclineNotification.text(notification.requestDecline.spaceName.withPlaceholder.trimmingCharacters(in: .whitespaces))
    }
}
