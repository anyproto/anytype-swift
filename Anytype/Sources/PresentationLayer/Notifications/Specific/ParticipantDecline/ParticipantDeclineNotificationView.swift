import Foundation
import SwiftUI

struct ParticipantDeclineNotificationView: View {

    @State private var model: ParticipantDeclineNotificationViewModel

    init(notification: NotificationParticipantRequestDecline) {
        _model = State(initialValue: ParticipantDeclineNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message,
                            buttons: [])
    }
}
