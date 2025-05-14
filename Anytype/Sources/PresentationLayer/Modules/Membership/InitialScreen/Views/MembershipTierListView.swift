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
                        MembershipTierView(tierToDisplay: tier) {
                            onTierTap(tier)
                        }
                        .id(tier)
                    }
                    
                    Spacer.fixedWidth(0)
                }
            }
            .onAppear {
                scrollView.scrollTo(MembershipTierType.builder, anchor: .center)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack {
            MembershipTierListView(
                userMembership: .mock(tier: nil, status: .unknown),
                tiers: [
                    MembershipTier.mockStarter,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: .mock(tier: .mockStarter, status: .pending),
                tiers: [
                    MembershipTier.mockStarter,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: .mock(tier: .mockStarter),
                tiers: [
                    MembershipTier.mockStarter,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: .mock(tier: .mockCustom),
                tiers: [
                    MembershipTier.mockCustom,
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }

            
            MembershipTierListView(
                userMembership: .mock(tier: .mockBuilder),
                tiers: [
                    MembershipTier.mockBuilder,
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
            
            MembershipTierListView(
                userMembership: .mock(tier: .mockCoCreator, status: .pending),
                tiers: [
                    MembershipTier.mockCoCreator
                ]
            ) { _ in }
        }
    }
}
