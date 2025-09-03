import Foundation
import SwiftUI
import Services

struct ChatDeleteMessageAlertData: Identifiable, Hashable {
    let chatId: String
    let messageId: String
    
    var id: Int { hashValue }
}

struct ChatDeleteMessageAlert: View {
    
    @StateObject private var model: ChatDeleteMessageAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ChatDeleteMessageAlertData) {
        self._model = StateObject(wrappedValue: ChatDeleteMessageAlertModel(data: data))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.DeleteMessage.title,
            message: Loc.Chat.DeleteMessage.description,
            icon: .Dialog.question
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
