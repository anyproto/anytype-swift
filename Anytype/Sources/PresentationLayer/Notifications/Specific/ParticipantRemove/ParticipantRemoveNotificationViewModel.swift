import Foundation
import Services

@MainActor
final class ParticipantRemoveNotificationViewModel: ObservableObject {
    
    private let notification: NotificationParticipantRemove
    
    @Published var message: String = ""
    
    init(notification: NotificationParticipantRemove) {
        self.notification = notification
        message = Loc.ParticipantRemoveNotification.text(notification.remove.spaceName.trimmingCharacters(in: .whitespaces))
    }
}
