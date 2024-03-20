import Foundation
import SwiftUI

struct RequestToJoinNotificationView: View {
    
    @StateObject private var model: RequestToJoinNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationRequestToJoin) {
        _model = StateObject(wrappedValue: RequestToJoinNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, icon: model.icon, buttons: [
            TopNotificationButton(title: Loc.RequestToJoinNotification.goToSpace) {
                try await model.onTapGoToSpace()
            },
            TopNotificationButton(title: Loc.RequestToJoinNotification.viewRequest) {
                model.onTapViewRequest()
            }
        ])
        .onChange(of: model.dismiss) { _ in dismiss() }
        .snackbar(toastBarData: $model.toast)
    }
}
