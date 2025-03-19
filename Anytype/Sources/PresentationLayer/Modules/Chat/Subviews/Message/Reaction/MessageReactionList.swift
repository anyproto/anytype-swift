import Foundation
import SwiftUI
import WrappingHStack

struct MessageReactionList: View {

    let rows: [MessageReactionModel]
    let canAddReaction: Bool
    let position: MessageHorizontalPosition
    let onTapRow: (MessageReactionModel) async throws -> Void
    let onLongTapRow: (MessageReactionModel) -> Void
    let onTapAdd: () -> Void
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8, fitContentWidth: true) {
            ForEach(rows.indices, id: \.self) { index in
                MessageReactionView(
                    model: rows[index],
                    onTap: { try await onTapRow(rows[index]) },
                    onLongTap: { onLongTapRow(rows[index]) }
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
        position: .right,
        onTapRow: { _ in },
        onLongTapRow: { _ in },
        onTapAdd: {}
    )
}
