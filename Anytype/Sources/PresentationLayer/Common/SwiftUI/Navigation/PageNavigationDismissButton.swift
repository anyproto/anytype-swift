import SwiftUI

struct PageNavigationDismissButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ExpandedTapAreaButton {
            dismiss()
        } label: {
            Image(asset: .X24.back)
                .navPanelDynamicForegroundStyle()
        }
    }
}
