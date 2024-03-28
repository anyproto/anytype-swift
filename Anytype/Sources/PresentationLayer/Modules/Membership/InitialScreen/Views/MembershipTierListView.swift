import SwiftUI
import Services


struct MembershipTierListView: View {
    let userMembership: MembershipStatus
    let tiers: [MembershipTier]
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(tiers) { tier in
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
                    tier: nil,
                    status: .unknown,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ), 
                tiers: [
                    MembershipTier.mockExplorer,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier.mockExplorer,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .mockExplorer,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier.mockExplorer,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .mockCustom,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier.mockCustom,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }

            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .mockBuilder,
                    status: .active,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .mockCoCreator,
                    status: .pending,
                    dateEnds: .tomorrow,
                    paymentMethod: .methodCard,
                    anyName: ""
                ),
                tiers: [
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
        }
    }
}
