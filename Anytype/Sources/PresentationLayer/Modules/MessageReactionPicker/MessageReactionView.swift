import Foundation
import SwiftUI

struct MessageReactionView: View {
    
    @StateObject private var model: MessageReactionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(messageId: String) {
        self._model = StateObject(wrappedValue: MessageReactionViewModel(messageId: messageId))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            EmojiGridView { emoji in
                model.onTapEmoji(emoji)
            }
        }
        .presentationDragIndicator(.hidden)
        .presentationDetents([.medium, .large])
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
}
