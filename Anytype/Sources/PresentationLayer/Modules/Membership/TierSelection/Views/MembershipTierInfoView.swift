import SwiftUI
import Services


struct MembershipTierInfoView: View {
    let tier: MembershipTier
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(36)
            Image(asset: tier.mediumIcon)
            Spacer.fixedHeight(14)
            AnytypeText(tier.name, style: .title, color: .Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(tier.subtitle, style: .calloutRegular, color: .Text.primary)
            Spacer.fixedHeight(22)
            whatsIncluded
            Spacer.fixedHeight(30)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .background(
            Group {
                if colorScheme == .dark {
                    Color.Shape.tertiary
                } else {
                    tier.gradient
                }
            }
        )
    }
    
    var whatsIncluded: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.whatSIncluded, style: .calloutRegular, color: .Text.secondary)
            Spacer.fixedHeight(6)
            ForEach(tier.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 8) {
                        Image(asset: .System.textCheckMark)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.Text.primary)
                            .padding(.top, 3)
                    AnytypeText(feature, style: .calloutRegular, color: .Text.primary)
                        .lineLimit(2)
                }
            }
        }
    }
}

#Preview {
    MembershipTierInfoView(tier: .mockExplorer)
}
