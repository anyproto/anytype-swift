import SwiftUI

struct ReindexingAlertView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.ReindexingWarningAlert.title,
            message: Loc.ReindexingWarningAlert.description,
            icon: .BottomAlert.update,
            style: .color(.green)
        ) {
            BottomAlertButton(text: Loc.gotIt, style: .primary) {
                dismiss()
            }
        }
    }
}

#Preview {
    ReindexingAlertView()
}
