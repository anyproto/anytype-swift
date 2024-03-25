import Foundation
import SwiftUI

struct ParticipantRemoveNotificationView: View {
    
    @StateObject private var model: ParticipantRemoveNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationParticipantRemove, onDelete: @escaping (_ spaceId: String) async -> Void) {
        _model = StateObject(wrappedValue: ParticipantRemoveNotificationViewModel(notification: notification, onDelete: onDelete))
    }
    
    var body: some View {
        TopNotificationView(
            title: model.message,
            buttons: [
                TopNotificationButton(title: Loc.export, action: {
                    model.onTapExport()
                }),
                TopNotificationButton(title: Loc.delete, action: {
                    await model.onTapDelete()
                })
            ]
        )
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
}
