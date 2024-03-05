import SwiftUI

struct MembershipTierSelectionView: View {
    let tier: MembershipTier
    
    var body: some View {
        VStack(spacing: 0) {
            info
            Spacer()
        }
    }
    
    var info: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(36)
            Image(asset: tier.mediumIcon)
            Spacer.fixedHeight(14)
            AnytypeText(tier.title, style: .title, color: .Text.primary)
            Spacer.fixedHeight(6)
            AnytypeText(tier.subtitle, style: .calloutRegular, color: .Text.primary)
            Spacer.fixedHeight(22)
            whatsIncluded
            Spacer.fixedHeight(30)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(tier.gradient)
    }
    
    var whatsIncluded: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(Loc.whatSIncluded, style: .calloutRegular, color: .Text.secondary)
            Spacer.fixedHeight(6)
            ForEach(tier.benefits, id: \.self) { benefit in
                HStack(spacing: 8) {
                    Image(asset: .X18.listArrow).frame(width: 16, height: 16)
                    AnytypeText(benefit, style: .calloutRegular, color: .Text.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    MembershipTierSelectionView(tier: .builder)
}
