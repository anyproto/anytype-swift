import SwiftUI

struct MembershipTierSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    let tier: MembershipTier
    
    var body: some View {
        BottomAlertView(
            title: Loc.Membership.Success.title(tier.title),
            message: Loc.Membership.Success.subitle,
            icon: .Membership.tierExplorerMedium,
            style: .red // TODO: Update style in design system
        ) {
            BottomAlertButton(text: Loc.done, style: .secondary) {
                dismiss()
            }
        }
    }
}

#Preview {
    MembershipTierSuccessView(tier: .builder)
}
