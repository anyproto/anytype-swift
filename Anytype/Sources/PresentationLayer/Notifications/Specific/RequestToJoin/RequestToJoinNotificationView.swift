import Foundation
import SwiftUI

struct RequestToJoinNotificationView: View {

    @State private var model: RequestToJoinNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss

    init(
        notification: NotificationRequestToJoin,
        onViewRequest: @escaping (_ notification: NotificationRequestToJoin) async -> Void
    ) {
        _model = State(initialValue: RequestToJoinNotificationViewModel(notification: notification, onViewRequest: onViewRequest))
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
        .onChange(of: model.dismiss) { dismiss() }
        .snackbar(toastBarData: $model.toast)
    }
}
