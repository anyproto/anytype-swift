import Foundation
import SwiftUI
import AnytypeCore

struct MessageReactionView: View {
    
    let model: MessageReactionModel
    let onTap: () async throws -> Void
    let onLongTap: () -> Void
    
    var body: some View {
        AsyncButton {
            try await onTap()
        } label: {
            HStack(spacing: 4) {
                Text(model.emoji)
                // Don't needed anytype style because emojy font will be replace to system
                    .font(.system(size: 18))
                switch model.content {
                case .count(let count):
                    Text("\(count)")
                        .anytypeFontStyle(.caption1Medium)
                        .foregroundColor(.Text.primary)
                        .frame(minWidth: 18)
                case .icon(let icon):
                    IconView(icon: icon)
                        .frame(width: 20, height: 20)
                }
                
            }
            .dynamicTypeSize(.large)
            .frame(height: 32)
            .padding(.horizontal, 8)
            .background(model.selected ? Color.VeryLight.orange : Color.Background.highlightedMedium)
            .cornerRadius(16, style: .circular)
            .border(16, color: model.selected ? Color.System.amber50 : Color.clear, lineWidth: 1)
        }
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.3)
                .onEnded { _ in
                    onLongTap()
                }
        )
    }
}

#Preview {
    VStack {
        MessageReactionView(
            model: MessageReactionModel(emoji: "😘", content: .count(4), selected: false),
            onTap: {},
            onLongTap: {}
        )
        MessageReactionView(
            model: MessageReactionModel(emoji: "😁", content: .icon(.asset(.X18.delete)), selected: true),
            onTap: {},
            onLongTap: {}
        )
    }
}
