import Foundation
import SwiftUI

struct PermissionChangeNotificationView: View {
    
    @StateObject private var model: PermissionChangeNotificationViewModel
    
    init(notification: NotificationParticipantPermissionsChange) {
        _model = StateObject(wrappedValue: PermissionChangeNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.message, icon: model.icon, buttons: [])
    }
}
