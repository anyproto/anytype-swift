import SwiftUI

struct DeleteSystemWidgetConfirmationData: Identifiable {
    let id = UUID()
    let onConfirm: () -> Void
}

struct DeleteSystemWidgetConfirmation: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let data: DeleteSystemWidgetConfirmationData
    
    var body: some View {
        BottomAlertView(
            title: Loc.Widgets.System.DeleteAlert.title,
            message: Loc.Widgets.System.DeleteAlert.message,
            icon: .Dialog.question
        ) {
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
            BottomAlertButton(text: Loc.delete, style: .warning) {
                data.onConfirm()
                dismiss()
            }
        }
    }
}
