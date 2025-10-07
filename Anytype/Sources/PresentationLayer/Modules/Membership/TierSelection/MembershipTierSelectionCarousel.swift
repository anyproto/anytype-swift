import SwiftUI
import Services


struct MembershipTierSelectionCarousel: View {
    
    private let userMembership: MembershipStatus
    private let allTiers: [MembershipTier]
    
    private let onSuccessfulPurchase: (MembershipTier) -> ()
    
    @State private var selection: MembershipTier.ID
    
    init(
        userMembership: MembershipStatus,
        allTiers: [MembershipTier],
        tierToDisplay: MembershipTier,
        onSuccessfulPurchase: @escaping (MembershipTier) -> ()
        
    ) {
        self.userMembership = userMembership
        self.allTiers = allTiers
        self.onSuccessfulPurchase = onSuccessfulPurchase
        _selection = State(initialValue: tierToDisplay.id)
    }
    
    var body: some View {
        TabView(selection: $selection.animation()) {
            ForEach(allTiers) { tier in
                MembershipTierSelectionView(
                    userMembership: userMembership,
                    tierToDisplay: tier,
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
        
        .onAppear {
            logScreenMembership()
        }
        .onChange(of: selection) {
            logScreenMembership()
        }
    }
    
    func logScreenMembership() {
        if let tier = allTiers.first(where: { $0.id == selection }) {
            AnytypeAnalytics.instance().logScreenMembership(tier: tier)
        }
    }
}

#Preview {
    NavigationView {
        MembershipTierSelectionCarousel(
            userMembership: .empty,
            allTiers: [ .mockStarter, .mockBuilder, .mockCoCreator ],
            tierToDisplay: .mockBuilder,
            onSuccessfulPurchase: { _ in }
        )
    }
}
