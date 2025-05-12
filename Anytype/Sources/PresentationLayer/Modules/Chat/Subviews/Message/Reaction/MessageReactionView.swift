import Foundation
import SwiftUI
import AnytypeCore

struct MessageReactionView: View {
    
    let model: MessageReactionModel
    let onTap: () async throws -> Void
    let onLongTap: () -> Void
    
    @Environment(\.messageYourBackgroundColor)
    private var messageYourBackgroundColor
    
    var body: some View {
        AsyncButton {
            try await onTap()
        } label: {
            HStack(spacing: 4) {
                Text(model.emoji)
                // Don't needed anytype style because emojy font will be replace to system
                    .font(.system(size: 14))
                switch model.content {
                case .count(let count):
                    Text("\(count)")
                        .anytypeFontStyle(.caption1Regular)
                        .foregroundColor(.Text.primary)
                case .icon(let icon):
                    IconView(icon: icon)
                        .frame(width: 20, height: 20)
                }
                
            }
            .dynamicTypeSize(.large)
            .frame(height: 28)
            .padding(.horizontal, 8)
            .background(model.selected ? messageYourBackgroundColor : Color.Background.Chat.bubbleSomeones)
            .cornerRadius(20)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.25)
                .onEnded { _ in
                    onLongTap()
                }
        )
    }
}

#Preview {
    VStack {
        MessageReactionView(
            model: MessageReactionModel(emoji: "😘", content: .count(4), selected: false, position: .left),
            onTap: {},
            onLongTap: {}
        )
        MessageReactionView(
            model: MessageReactionModel(emoji: "😁", content: .icon(.asset(.X18.delete)), selected: true, position: .right),
            onTap: {},
            onLongTap: {}
        )
    }
}
