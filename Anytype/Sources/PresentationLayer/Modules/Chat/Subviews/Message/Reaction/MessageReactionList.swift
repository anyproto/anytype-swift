import Foundation
import SwiftUI
import WrappingHStack

struct MessageReactionList: View {

    let rows: [MessageReactionModel]
    let canAddReaction: Bool
    let canToggleReaction: Bool
    let position: MessageHorizontalPosition
    let onTapRow: (MessageReactionModel) async throws -> Void
    let onLongTapRow: (MessageReactionModel) -> Void
    let onTapAdd: () -> Void
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8, fitContentWidth: true) {
            ForEach(rows, id: \.emoji) { reaction in
                MessageReactionView(
                    model: reaction,
                    canToggle: canToggleReaction,
                    onTap: { try await onTapRow(reaction) },
                    onLongTap: { onLongTapRow(reaction) }
                )
            }
            if rows.isNotEmpty && canAddReaction {
                MessageReactionAddView(position: position, onTap: onTapAdd)
            }
        }
    }
}

#Preview {
    MessageReactionList(
        rows: [
            MessageReactionModel(emoji: "😍", content: .count(2), selected: false, position: .left),
            MessageReactionModel(emoji: "😗", content: .count(100), selected: true, position: .left),
            MessageReactionModel(emoji: "😎", content: .icon(.asset(.X18.delete)), selected: false, position: .right)
        ],
        canAddReaction: true,
        canToggleReaction: true,
        position: .right,
        onTapRow: { _ in },
        onLongTapRow: { _ in },
        onTapAdd: {}
    )
}
