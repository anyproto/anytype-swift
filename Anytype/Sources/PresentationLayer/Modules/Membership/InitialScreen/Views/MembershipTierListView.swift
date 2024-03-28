import SwiftUI
import Services


struct MembershipTierListView: View {
    let userMembership: MembershipStatus
    let tiers: [MembershipTier]
    let onTierTap: (MembershipTierId) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(tiers.map { $0.id }) { tier in
                        MembershipTeirView(tierToDisplay: tier, userMembership: userMembership) {
                            onTierTap(tier)
                        }
                        .id(tier)
                    }
                    
                    Spacer.fixedWidth(0)
                }
            }
            .onAppear {
                scrollView.scrollTo(MembershipTierId.builder, anchor: .center)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: nil,
                    status: .unknown,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ), 
                tiers: [
                    MembershipTier(id: .explorer),
                    MembershipTier(id: .builder),
                    MembershipTier(id: .coCreator)
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: .explorer,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier(id: .explorer),
                    MembershipTier(id: .builder),
                    MembershipTier(id: .coCreator),
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: .explorer,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier(id: .explorer),
                    MembershipTier(id: .builder),
                    MembershipTier(id: .coCreator)
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: .custom(id: 0),
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier(id: .custom(id: 0)),
                    MembershipTier(id: .builder),
                    MembershipTier(id: .coCreator)
                ]
            ) { _ in }

            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: .builder,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier(id: .builder),
                    MembershipTier(id: .coCreator)
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tierId: .coCreator,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier(id: .coCreator)
                ]
            ) { _ in }
        }
    }
}
