import Foundation
import SwiftUI

struct TopNotificationView: View {
    
    let title: String
    let buttons: [TopNotificationButton]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AnytypeText(title, style: .caption1Regular, color: .Text.labelInversion)
                Spacer()
            }
            HStack(spacing: 24) {
                ForEach(0..<buttons.count, id: \.self) { index in
                    let button = buttons[index]
                    Button {
                        button.action()
                    } label: {
                        AnytypeText(button.title, style: .caption1Semibold, color: .Text.labelInversion)
                    }
                }
            }
        }
        .padding(EdgeInsets(horizontal: 20, vertical: 16))
        .background(Color.Text.primary)
        .cornerRadius(16, style: .continuous)
        .ignoresSafeArea()
    }
}

struct TopNotificationButton {
    let title: String
    let action: () -> Void
}
