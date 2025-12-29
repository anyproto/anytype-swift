import Foundation
import SwiftUI

struct ParticipantRemoveNotificationView: View {

    @State private var model: ParticipantRemoveNotificationViewModel

    init(notification: NotificationParticipantRemove) {
        _model = State(initialValue: ParticipantRemoveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(
            title: model.message,
            buttons: []
        )
    }
}
