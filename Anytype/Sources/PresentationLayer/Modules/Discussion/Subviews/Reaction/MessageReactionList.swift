import Foundation
import SwiftUI
import WrappingHStack

struct MessageReactionList: View {

    let rows: [MessageReactionModel]
    let onTapRow: (MessageReactionModel) -> Void
    let onTapAdd: () -> Void
    
    var body: some View {
        WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8, fitContentWidth: true) {
            ForEach(rows.indices, id: \.self) { index in
                MessageReactionView(model: rows[index], onTap: { onTapRow(rows[index]) })
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
            MessageReactionModel(emoji: "😍", count: 2, selected: false),
            MessageReactionModel(emoji: "😗", count: 50, selected: true),
            MessageReactionModel(emoji: "😎", count: 150, selected: false)
        ],
        onTapRow: { _ in },
        onTapAdd: {}
    )
}
