import SwiftUI
import Services
import AnytypeCore


struct MembershipPricingView: View {
    let tier: MembershipTier
    
    var body: some View {
        switch tier.paymentType {
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
        case nil:
            Rectangle().hidden().onAppear {
                anytypeAssertionFailure(
                    "No pricing view for empty payment info",
                    info: ["Tier": String(reflecting: tier)]
                )
            }
        }
    }
}

#Preview {
    MembershipPricingView(tier: .mockBuilder)
}
