import Foundation
import SwiftUI

struct BinConfirmationAlert: View {
    
    @StateObject private var model: BinConfirmationAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: BinConfirmationAlertData) {
        self._model = StateObject(wrappedValue: BinConfirmationAlertModel(data: data))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.areYouSureYouWantToDelete(model.count),
            message: Loc.theseObjectsWillBeDeletedIrrevocably
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.delete, style: .warning) {
                try await model.onConfirm()
                dismiss()
            }
        }
        .onAppear {
            model.onAppear()
        }
        .snackbar(toastBarData: $model.toastData)
    }
}
