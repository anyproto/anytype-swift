import Foundation
import SwiftUI

struct PermissionChangeNotificationView: View {

    @State private var model: PermissionChangeNotificationViewModel

    init(notification: NotificationParticipantPermissionsChange) {
        _model = State(initialValue: PermissionChangeNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, buttons: [])
    }
}
