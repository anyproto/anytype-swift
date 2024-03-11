import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let actionText: String
    let action: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ButtomAlertHeaderImageView(icon: .BottomAlert.error, style: .color(.red))
            Spacer.fixedHeight(12)
            AnytypeText(title, style: .uxCalloutMedium, color: .Text.primary)
                .multilineTextAlignment(.center)
            AnytypeText(subtitle, style: .uxCalloutRegular, color: .Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(12)
            StandardButton(actionText, style: .secondarySmall) {
                action()
            }
            Spacer.fixedHeight(48)
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    EmptyStateView(
        title: Loc.Relation.EmptyState.title,
        subtitle: Loc.Relation.EmptyState.description,
        actionText: Loc.create
    ) { }
}
