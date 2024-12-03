import Foundation
import SwiftUI
import WrappingHStack

struct MessageReactionList: View {

    let rows: [MessageReactionModel]
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
            if rows.isNotEmpty {
                MessageReactionAddView(onTap: onTapAdd)
            }
        }
    }
}

#Preview {
    MessageReactionList(
        rows: [
            MessageReactionModel(emoji: "😍", content: .count(2), selected: false),
            MessageReactionModel(emoji: "😗", content: .count(100), selected: true),
            MessageReactionModel(emoji: "😎", content: .icon(.asset(.X18.delete)), selected: false)
        ],
        onTapRow: { _ in },
        onLongTapRow: { _ in },
        onTapAdd: {}
    )
}
