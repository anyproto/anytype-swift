import SwiftUI
import Services


struct MembershipPricingView: View {
    let tier: MembershipTier
    
    var body: some View {
        switch tier.paymentType {
        case .email:
            AnytypeText(Loc.justEMail, style: .bodySemibold, color: .Text.primary)
        case .appStore(let product):
            AnytypeText("\(product.anytypeDisplayPrice) ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(product.localizedPeriod ?? "", style: .caption1Regular, color: .Text.primary)
        case .external(let info):
            AnytypeText("\(info.displayPrice) ", style: .bodySemibold, color: .Text.primary) +
            AnytypeText(info.localizedPeriod ?? "", style: .caption1Regular, color: .Text.primary)
        }
    }
}

#Preview {
    MembershipPricingView(tier: .mockBuilder)
}
