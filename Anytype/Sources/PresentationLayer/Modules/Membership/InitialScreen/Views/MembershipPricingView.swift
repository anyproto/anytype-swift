import SwiftUI
import Services


struct MembershipPricingView: View {
    let tier: MembershipTier
    
    var body: some View {
        switch tier.paymentType {
        case .email:
            AnytypeText(Loc.justEMail, style: .bodySemibold)
                .foregroundColor(.Text.primary)
        case .appStore(let product):
            AnytypeText("\(product.anytypeDisplayPrice) ", style: .bodySemibold)
                .foregroundColor(.Text.primary) +
            AnytypeText(product.localizedPeriod ?? "", style: .caption1Regular)
                .foregroundColor(.Text.primary)
        case .external(let info):
            AnytypeText("\(info.displayPrice) ", style: .bodySemibold)
                .foregroundColor(.Text.primary) +
            AnytypeText(info.localizedPeriod ?? "", style: .caption1Regular)
                .foregroundColor(.Text.primary)
        }
    }
}

#Preview {
    MembershipPricingView(tier: .mockBuilder)
}
