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
        AnytypeAnalytics.instance().logScreenMembership(tier: tierToDisplay)
    }
    
    var body: some View {
        TabView(selection: $selection.animation()) {
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
        .background(Color.Background.primary)
        
        .overlay(alignment: .top) {
            AnytypeIndexView(
                numberOfPages: allTiers.count,
                currentIndex: allTiers.map { $0.id }.firstIndex(of: selection) ?? 0
            )
            .padding()
        }
        .ignoresSafeArea(.container)
        
        .onChange(of: selection) { selection in
            if let tier = allTiers.first(where: { $0.id == selection }) {
                AnytypeAnalytics.instance().logScreenMembership(tier: tier)
            }
        }
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
