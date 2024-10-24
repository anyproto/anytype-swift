import Foundation
import SwiftUI

struct ParticipantRemoveNotificationView: View {
    
    @StateObject private var model: ParticipantRemoveNotificationViewModel
    
    init(notification: NotificationParticipantRemove) {
        _model = StateObject(wrappedValue: ParticipantRemoveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(
            title: model.message,
            buttons: []
        )
    }
}
