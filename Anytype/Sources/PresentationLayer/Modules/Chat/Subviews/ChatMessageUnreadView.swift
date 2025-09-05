import SwiftUI

struct ChatMessageUnreadView: View {
    
    static let height: CGFloat = 50
    
    var body: some View {
        HStack {
            Spacer()
            Text(Loc.Chat.newMessages)
                .anytypeStyle(.caption1Medium)
                .foregroundColor(.Control.transparentSecondary)
                .frame(height: Self.height)
                .lineLimit(1)
            Spacer()
        }
    }
}
