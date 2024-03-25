import Foundation
import SwiftUI

struct ParticipantDeclineNotificationView: View {
    
    @StateObject private var model: ParticipantDeclineNotificationViewModel
    
    init(notification: NotificationParticipantRequestDecline) {
        _model = StateObject(wrappedValue: ParticipantDeclineNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message,
                            buttons: [])
    }
}
