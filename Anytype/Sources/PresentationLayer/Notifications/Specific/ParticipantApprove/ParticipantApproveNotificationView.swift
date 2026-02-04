import Foundation
import SwiftUI

struct ParticipantApproveNotificationView: View {

    @State private var model: ParticipantApproveNotificationViewModel

    init(notification: NotificationParticipantRequestApproved) {
        _model = State(initialValue: ParticipantApproveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, buttons: [])
    }
}
