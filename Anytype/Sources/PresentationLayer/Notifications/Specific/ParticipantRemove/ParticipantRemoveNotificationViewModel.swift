import Foundation
import Services

@MainActor
@Observable
final class ParticipantRemoveNotificationViewModel {

    private let notification: NotificationParticipantRemove

    var message: String = ""
    
    init(notification: NotificationParticipantRemove) {
        self.notification = notification
        message = Loc.ParticipantRemoveNotification.text(notification.remove.spaceName.trimmingCharacters(in: .whitespaces))
    }
}
