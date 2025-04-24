import Foundation
import SwiftUI
import Services

struct ChatDeleteMessageAlert: View {
    
    @StateObject private var model: ChatDeleteMessageAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(message: MessageViewData) {
        self._model = StateObject(wrappedValue: ChatDeleteMessageAlertModel(message: message))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.DeleteMessage.title,
            message: Loc.Chat.DeleteMessage.description,
            icon: .BottomAlert.question
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        
            BottomAlertButton(text: Loc.delete, style: .warning) {
                try await model.onTapDelete()
                dismiss()
            }
        }
    }
    
}
