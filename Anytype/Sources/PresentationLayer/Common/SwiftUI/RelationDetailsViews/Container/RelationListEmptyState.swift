import SwiftUI

struct RelationListEmptyState: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(24)
            Image(asset: .BottomAlert.error)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Relation.EmptyState.Blocked.title, style: .uxCalloutMedium)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(24)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    RelationListEmptyState()
}
