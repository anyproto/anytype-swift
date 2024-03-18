import Foundation
import SwiftUI

struct TopNotificationView: View {
    
    var title: String
    var icon: Icon? = nil
    var buttons: [TopNotificationButton]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                if let icon {
                    IconView(icon: icon)
                        .frame(width: 40, height: 40)
                }
                AnytypeText(title, style: .caption1Regular, color: .Text.labelInversion, enableMarkdown: true)
                Spacer()
            }
            if buttons.isNotEmpty {
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
        }
        .padding(EdgeInsets(horizontal: 20, vertical: 16))
        .background(Color.Text.primary)
        .cornerRadius(16, style: .continuous)
        .ignoresSafeArea()
        .environment(\.colorScheme, .light)
    }
}

struct TopNotificationButton {
    let title: String
    let action: () -> Void
}

#Preview("Single Line") {
    TopNotificationView(title: "One **line**", icon: .asset(.X40.audio), buttons: [
        TopNotificationButton(title: "Button 1", action: {})
    ])
}

#Preview("Multi line") {
    TopNotificationView(title: "Notification text Notification text Notification text Notification text Notification text Notification text Notification text", buttons: [])
}
