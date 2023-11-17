import Foundation
import SwiftUI

struct SpaceWidgetView: View {
    
    @ObservedObject var model: SpaceWidgetViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            IconView(icon: model.spaceIcon)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 1) {
                AnytypeText(model.spaceName, style: .previewTitle2Medium, color: .Text.primary)
                    .lineLimit(1)
                AnytypeText(model.spaceAccessibility, style: .relation3Regular, color: .Text.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 68)
        .background(Color.Widget.card)
        .cornerRadius(16, style: .continuous)
        .onTapGesture {
            model.onTapWidget()
        }
    }
}
