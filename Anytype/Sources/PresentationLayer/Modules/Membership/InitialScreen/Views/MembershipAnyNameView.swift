import SwiftUI


// Outlined block prompting the user to claim their `.any` name (paid tiers only).
// Only shown while no name is set yet — see MembershipTierRecommendation.showAnyName.
struct MembershipAnyNameView: View {
    let onSelectNameTap: () -> ()

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(24)
            Image(asset: .Membership.anyName)
                .resizable()
                .frame(width: 60, height: 48)
            Spacer.fixedHeight(12)
            AnytypeText(Loc.Membership.selectAnyName, style: .previewTitle1Medium)
                .foregroundStyle(Color.Text.primary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(4)
            AnytypeText(Loc.Membership.AnyName.description, style: .relation2Regular)
                .foregroundStyle(Color.Text.secondary)
                .multilineTextAlignment(.center)
            Spacer.fixedHeight(16)
            StandardButton(.text(Loc.Membership.AnyName.select), style: .primaryMedium) {
                onSelectNameTap()
            }
            .frame(maxWidth: 200)
            Spacer.fixedHeight(24)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.Shape.transparentSecondary, lineWidth: 1)
        )
    }
}

#Preview {
    MembershipAnyNameView(onSelectNameTap: {})
        .padding(16)
}
