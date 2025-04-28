import SwiftUI
import Services


struct MembershipTierSuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    let tier: MembershipTier
    
    var body: some View {
        BottomAlertView(
            title: Loc.Membership.Success.title(tier.name),
            message: tier.successMessage,
            icon: tier.mediumIcon
        ) {
            BottomAlertButton(text: Loc.done, style: .secondary) {
                dismiss()
            }
        }
    }
}

#Preview {
    MembershipTierSuccessView(tier: .mockBuilder)
}
