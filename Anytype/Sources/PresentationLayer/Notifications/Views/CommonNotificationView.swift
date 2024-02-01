import Foundation
import SwiftUI

struct CommonNotificationView: View {
    
    @StateObject var model: CommonNotificationViewModel
    
    var body: some View {
        HStack {
            AnytypeText(model.title, style: .caption1Regular, color: .Text.labelInversion)
            Spacer()
        }
        .padding(EdgeInsets(horizontal: 20, vertical: 16))
        .background(Color.Text.primary)
        .cornerRadius(16, style: .continuous)
        .ignoresSafeArea()
    }
}
