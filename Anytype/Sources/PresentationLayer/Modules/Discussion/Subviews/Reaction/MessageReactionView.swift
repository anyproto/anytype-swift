import Foundation
import SwiftUI
import AnytypeCore

struct MessageReactionView: View {
    
    let model: MessageReactionModel
    let onTap: () async throws -> Void
    
    var body: some View {
        AsyncButton {
            try await onTap()
        } label: {
            HStack(spacing: 2) {
                Text(model.emoji)
                // Don't needed anytype style because emojy font will be replace to system
                    .font(.system(size: 18))
                Text("\(model.count)")
                    .anytypeFontStyle(.caption1Medium)
                    .foregroundColor(.Text.primary)
                    .padding(.horizontal, 5)
            }
            .dynamicTypeSize(.large)
            .frame(height: 32)
            .padding(.horizontal, 6)
            .background(model.selected ? Color.Button.inactive : Color.Background.highlightedMedium)
            .cornerRadius(16, style: .circular)
            .border(16, color: model.selected ? Color.Button.button : Color.clear, lineWidth: 1)
        }
    }
}

#Preview {
    VStack {
        MessageReactionView(
            model: MessageReactionModel(emoji: "😘", count: 4, selected: false),
            onTap: {}
        )
        MessageReactionView(
            model: MessageReactionModel(emoji: "😁", count: 4, selected: true),
            onTap: {}
        )
    }
}
