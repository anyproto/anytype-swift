import Foundation
import SwiftUI

struct ParticipantRemoveNotificationView: View {
    
    @StateObject private var model: ParticipantRemoveNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationParticipantRemove, onExport: @escaping (_ path: URL) async -> Void) {
        _model = StateObject(wrappedValue: ParticipantRemoveNotificationViewModel(notification: notification, onExport: onExport))
    }
    
    var body: some View {
        TopNotificationView(
            title: model.message,
            buttons: [
                TopNotificationButton(title: Loc.export, action: {
                    try await model.onTapExport()
                }),
            ]
        )
        .onChange(of: model.dismiss) { _ in dismiss() }
    }
}
