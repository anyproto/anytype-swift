import Foundation
import SwiftUI

struct MessageReactionPickerView: View {
    
    @StateObject private var model: MessageReactionPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: MessageReactionPickerData) {
        self._model = StateObject(wrappedValue: MessageReactionPickerViewModel(data: data))
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
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }
}
