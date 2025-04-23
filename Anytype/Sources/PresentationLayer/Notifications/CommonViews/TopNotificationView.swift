import Foundation
import SwiftUI

struct TopNotificationView: View {
    
    var title: String
    var icon: Icon? = nil
    var buttons: [TopNotificationButton]
    
    @State private var toast: ToastBarData?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let icon {
                IconView(icon: icon)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading, spacing: 10) {
                AnytypeText(title, style: .caption1Regular, enableMarkdown: true)
                    .foregroundColor(.Text.inversion)
                if buttons.isNotEmpty {
                    HStack(spacing: 24) {
                        ForEach(0..<buttons.count, id: \.self) { index in
                            let button = buttons[index]
                            AsyncButton {
                                try await button.action()
                            } label: {
                                AnytypeText(button.title, style: .caption1Semibold)
                                    .foregroundColor(.Text.inversion)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(horizontal: 20, vertical: 16))
        .background(Color.Text.primary)
        .cornerRadius(16, style: .continuous)
        .ignoresSafeArea()
        .snackbar(toastBarData: $toast)
        .environment(\.colorScheme, .light)
    }
}

struct TopNotificationButton: Equatable {
    let title: String
    @EquatableNoop
    var action: () async throws -> Void
}

#Preview("Single Line") {
    TopNotificationView(title: "One **line**", icon: .asset(.X40.audio), buttons: [
        TopNotificationButton(title: "Button 1", action: {})
    ])
}

#Preview("Multi line") {
    TopNotificationView(title: "Notification text Notification text Notification text Notification text Notification text Notification text Notification text", buttons: [])
}
