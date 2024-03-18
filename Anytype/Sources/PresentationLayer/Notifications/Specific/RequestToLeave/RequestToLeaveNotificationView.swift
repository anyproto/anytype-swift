import Foundation
import SwiftUI

struct RequestToLeaveNotificationView: View {
    
    @StateObject private var model: RequestToLeaveNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationRequestToLeave) {
        _model = StateObject(wrappedValue: RequestToLeaveNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, icon: model.icon, buttons: [
            TopNotificationButton(title: Loc.SpaceShare.Action.approve) {
                try await model.onTapApprove()
            }
        ])
        .onChange(of: model.dismiss) { _ in dismiss() }
        .snackbar(toastBarData: $model.toast)
    }
}
