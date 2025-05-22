import SwiftUI

struct PropertyListEmptyState: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(24)
            Image(asset: .Dialog.duck)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relation.EmptyState.Blocked.title, style: .uxCalloutMedium)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(24)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    PropertyListEmptyState()
}
