import Foundation
import SwiftUI

struct CommonNotificationView: View {
    
    @StateObject var model: CommonNotificationViewModel
    
    var body: some View {
        TopNotificationView(title: model.title, buttons: [])
    }
}
