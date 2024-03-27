import Foundation
import SwiftUI

struct RequestToJoinNotificationView: View {
    
    @StateObject private var model: RequestToJoinNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(
        notification: NotificationRequestToJoin,
        onViewRequest: @escaping (_ notification: NotificationRequestToJoin) async -> Void
    ) {
        _model = StateObject(wrappedValue: RequestToJoinNotificationViewModel(notification: notification, onViewRequest: onViewRequest))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, buttons: [
            TopNotificationButton(title: Loc.RequestToJoinNotification.goToSpace) {
                try await model.onTapGoToSpace()
            },
            TopNotificationButton(title: Loc.RequestToJoinNotification.viewRequest) {
                try await model.onTapViewRequest()
            }
        ])
        .onChange(of: model.dismiss) { _ in dismiss() }
        .snackbar(toastBarData: $model.toast)
    }
}
