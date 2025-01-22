import SwiftUI

struct ObjectFieldsBottomAlert: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        BottomAlertView(title: Loc.Fields.local, message: Loc.Fields.missingInfo) {
            BottomAlertButton(text: Loc.gotIt, style: .secondary) {
                dismiss()
            }
        }
    }
}

#Preview {
    ObjectFieldsBottomAlert()
}
