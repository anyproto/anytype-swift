import Foundation
import SwiftUI

struct GalleryNotificationView: View {
    
    @StateObject var model: GalleryNotificationViewModel
    
    var body: some View {
        TopNotificationView(title: model.title, buttons: [
            TopNotificationButton(title: Loc.Gallery.Notification.button, action: {
                model.onTapSpace()
            })
        ])
    }
}
