import SwiftUI
import Services
import AnytypeCore


struct MembershipPricingView: View {
    let tier: MembershipTier
    
    var body: some View {
        switch tier.paymentType {
        case .appStore(let info):
            AnytypeText("\(info.product.anytypeDisplayPrice) ", style: .bodySemibold)
                .foregroundColor(.Text.primary) +
            AnytypeText(info.product.localizedPeriod ?? "", style: .caption1Regular)
                .foregroundColor(.Text.primary)
        case .external(let info):
            AnytypeText("\(info.displayPrice) ", style: .bodySemibold)
                .foregroundColor(.Text.primary) +
            AnytypeText(info.localizedPeriod ?? "", style: .caption1Regular)
                .foregroundColor(.Text.primary)
        case nil:
            Rectangle().hidden().task {
                anytypeAssertionFailure(
                    "No pricing view for empty payment info",
                    info: [
                        "Tier": String(reflecting: tier),
                        "Status": String(reflecting: await Container.shared.membershipStatusStorage.resolve().currentStatus())
                    ]
                )
            }
        }
    }
}

#Preview {
    MembershipPricingView(tier: .mockBuilder)
}
