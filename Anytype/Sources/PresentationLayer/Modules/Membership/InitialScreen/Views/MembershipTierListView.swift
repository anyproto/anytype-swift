import SwiftUI
import Services


struct MembershipTierListView: View {
    let userMembership: MembershipStatus
    let onTierTap: (MembershipTier) -> ()
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Spacer.fixedWidth(0)
                    
                    ForEach(userMembership.tier.availableTiers) { tier in
                        MembershipTeirView(tierToDisplay: tier, userMembership: userMembership) {
                            onTierTap(tier)
                        }
                        .id(tier)
                    }
                    
                    Spacer.fixedWidth(0)
                }
            }
            .onAppear {
                scrollView.scrollTo(MembershipTier.builder, anchor: .center)
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
                    status: .statusUnknown,
                    dateEnds: .tomorrow
                )
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusPending,
                    dateEnds: .tomorrow
                )
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .explorer,
                    status: .statusActive,
                    dateEnds: .tomorrow
                )
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .custom(id: 0),
                    status: .statusActive,
                    dateEnds: .tomorrow
                )
            ) { _ in }

            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .builder,
                    status: .statusActive,
                    dateEnds: .tomorrow
                )
            ) { _ in }
            
            MembershipTierListView(
                userMembership: MembershipStatus(
                    tier: .coCreator,
                    status: .statusPending,
                    dateEnds: .tomorrow
                )
            ) { _ in }
        }
    }
}
