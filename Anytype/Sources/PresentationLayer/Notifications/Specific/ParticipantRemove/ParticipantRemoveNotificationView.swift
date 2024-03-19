import Foundation
import SwiftUI

struct ParticipantRemoveNotificationView: View {
    
    @StateObject private var model: ParticipantRemoveNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationParticipantRemove) {
        _model = StateObject(wrappedValue: ParticipantRemoveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(
            title: model.message,
            buttons: [
                TopNotificationButton(title: Loc.export, action: {
                    model.onTapExport()
                }),
                TopNotificationButton(title: Loc.delete, action: {
                    model.onTapDelete()
                })
            ]
        )
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
}
