import SwiftUI
import DesignKit

struct ChatDeleteChatAlert: View {

    @Environment(\.dismiss) private var dismiss
    private let onDelete: () async throws -> Void

    init(onDelete: @escaping () async throws -> Void) {
        self.onDelete = onDelete
    }

    var body: some View {
        BottomAlertView(
            title: Loc.Chat.DeleteChat.title,
            message: Loc.Chat.DeleteChat.description,
            icon: .Dialog.question
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }

            BottomAlertButton(text: Loc.moveToBin, style: .warning) {
                try await onDelete()
                dismiss()
            }
        }
    }
}
