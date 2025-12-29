import SwiftUI

struct AnyIdBottomSheetView: View {

    let onExplorePlansTap: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        BottomAlertView(
            title: Loc.Settings.AnyId.BottomSheet.title,
            message: Loc.Settings.AnyId.BottomSheet.description,
            icon: .Dialog.passport
        ) {
            BottomAlertButton(text: Loc.Settings.AnyId.BottomSheet.button, style: .primary) {
                dismiss()
                onExplorePlansTap()
            }
        }
    }
}
