import SwiftUI

struct SpaceTypeChangeConfirmationAlert: View {

    let onTapConvert: () async throws -> Void
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BottomAlertView(
            title: Loc.ConvertChannelTypeAlert.title,
            message: Loc.ConvertChannelTypeAlert.message,
            icon: .Dialog.question
        ) {
            BottomAlertButton(text: Loc.ConvertChannelTypeAlert.confirm, style: .primary) {
                try await onTapConvert()
                if #available(iOS 16.4, *) {
                } else {
                    dismiss()
                }
            }
        
            BottomAlertButton(text: Loc.cancel, style: .secondary) {
                dismiss()
            }
        }
    }
}



