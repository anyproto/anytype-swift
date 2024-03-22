import Foundation
import SwiftUI

struct ParticipantApproveNotificationView: View {
    
    @StateObject private var model: ParticipantApproveNotificationViewModel
    
    init(notification: NotificationParticipantRequestApproved) {
        _model = StateObject(wrappedValue: ParticipantApproveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, buttons: [])
    }
}
