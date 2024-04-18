import SwiftUI
import Services


struct MembershipTierSelectionCarousel: View {
    
    private let userMembership: MembershipStatus
    private let allTiers: [MembershipTier]
    
    private let onSuccessfulPurchase: (MembershipTier) -> ()
    private let showEmailVerification: (EmailVerificationData) -> ()
    
    @State private var selection: MembershipTier.ID
    
    init(
        userMembership: MembershipStatus,
        allTiers: [MembershipTier],
        tierToDisplay: MembershipTier,
        showEmailVerification: @escaping (EmailVerificationData) -> (),
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
        
    ) {
        self.userMembership = userMembership
        self.allTiers = allTiers
        self.showEmailVerification = showEmailVerification
        self.onSuccessfulPurchase = onSuccessfulPurchase
        _selection = State(initialValue: tierToDisplay.id)
    }
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(allTiers) { tier in
                MembershipTierSelectionView(
                    userMembership: userMembership,
                    tierToDisplay: tier,
                    showEmailVerification: showEmailVerification,
                    onSuccessfulPurchase: onSuccessfulPurchase
                ).id(tier.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationView {
        MembershipTierSelectionCarousel(
            userMembership: .empty,
            allTiers: [ .mockExplorer, .mockBuilder, .mockCoCreator ],
            tierToDisplay: .mockBuilder,
            showEmailVerification: { _ in },
            onSuccessfulPurchase: { _ in }
        )
    }
}
