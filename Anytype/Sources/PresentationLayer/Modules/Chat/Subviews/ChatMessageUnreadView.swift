import SwiftUI

struct ChatMessageUnreadView: View {
    
    var body: some View {
        HStack {
            Spacer()
            Text(Loc.Chat.newMessages)
                .anytypeStyle(.caption1Medium)
                .foregroundColor(.Control.transparentSecondary)
                .frame(height: 50)
                .lineLimit(1)
            Spacer()
        }
    }
}
