import Foundation
import SwiftUI

struct ObjectTypeDeleteConfirmationAlertData: Identifiable {
    let typeId: String
    
    var id: String { typeId }
}

struct ObjectTypeDeleteConfirmationAlert: View {

    @Environment(\.dismiss) private var dismiss
    @State private var model: ObjectTypeDeleteConfirmationAlertViewModel

    init(data: ObjectTypeDeleteConfirmationAlertData) {
        self._model = State(initialValue: ObjectTypeDeleteConfirmationAlertViewModel(data: data))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.ObjectTypeDeleteAlert.title,
            message: Loc.ObjectTypeDeleteAlert.message,
            icon: .Dialog.question
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.delete, style: .warning) {
                try await model.onTapDelete()
            }
        }
    }
}
