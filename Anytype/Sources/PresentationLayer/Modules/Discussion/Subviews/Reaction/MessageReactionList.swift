import Foundation
import SwiftUI
import WrappingHStack

struct MessageReactionList: View {
    
    private enum WrappingStackRow {
        case row(MessageReactionModel)
        case addItem
    }
    
    let rows: [MessageReactionModel]
    let onTapRow: (MessageReactionModel) -> Void
    let onTapAdd: () -> Void
    
    private let wrappingRows: [WrappingStackRow]
    
    init(
        rows: [MessageReactionModel],
        onTapRow: @escaping (MessageReactionModel) -> Void,
        onTapAdd: @escaping () -> Void
    ) {
        self.rows = rows
        self.onTapRow = onTapRow
        self.onTapAdd = onTapAdd
        self.wrappingRows = Self.makeWrappingRows(rows: rows)
    }
    
    var body: some View {
        WrappingHStack(wrappingRows.indices, id: \.self, spacing: .constant(8), lineSpacing: 8) { index in
            switch wrappingRows[index] {
            case let .row(model):
                MessageReactionView(model: model, onTap: { onTapRow(model) })
            case .addItem:
                MessageReactionAddView(onTap: onTapAdd)
            }
        }
    }
    
    private static func makeWrappingRows(rows: [MessageReactionModel]) -> [WrappingStackRow] {
        var wrappingRows: [WrappingStackRow] = rows.map { .row($0) }
        if rows.isNotEmpty {
            wrappingRows.append(.addItem)
        }
        return wrappingRows
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
