import Foundation
import SwiftUI

struct GalleryNotificationView: View {
    
    @StateObject var model: GalleryNotificationViewModel
    @Environment(\.notificationDismiss) private var dismiss
    
    init(notification: NotificationGalleryImport) {
        _model = StateObject(wrappedValue: GalleryNotificationViewModel(notification: notification))
    }
    
    var body: some View {
        TopNotificationView(title: model.title, buttons: [
            TopNotificationButton(title: Loc.Gallery.Notification.button, action: {
                model.onTapSpace()
                dismiss()
            })
        ])
    }
}
