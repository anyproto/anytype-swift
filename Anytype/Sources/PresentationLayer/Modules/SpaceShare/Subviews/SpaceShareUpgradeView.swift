import SwiftUI


struct SpaceShareUpgradeView: View {
    let reason: MembershipParticipantUpgradeReason
    let onTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(reason.warningText, style: .caption1Regular)
                .foregroundColor(Color.Text.primary)
            Spacer.fixedHeight(12)
            StandardButton("\(MembershipConstants.membershipSymbol.rawValue) \(Loc.upgrade)", style: .upgradeBadge) {
                onTap()
            }
            Spacer.fixedHeight(24)
        }
    }
}

#Preview {
    SpaceShareUpgradeView(reason: .numberOfSpaceEditors) { }
}
