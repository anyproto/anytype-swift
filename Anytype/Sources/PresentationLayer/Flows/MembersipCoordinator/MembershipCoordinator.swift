import SwiftUI
import Services


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    @Environment(\.openURL) private var openURL
    
    init(initialTierId: Int? = nil) {
        _model = StateObject(wrappedValue: MembershipCoordinatorModel(initialTierId: initialTierId))
    }
    
    var body: some View {
        Group {
            if model.showTiersLoadingError {
                errorView
            } else {
                MembershipModuleView(
                    membership: model.userMembership,
                    tiers: model.tiers
                ) { tier in
                    model.onTierSelected(tier: tier)
                }
                .overlay(alignment: .bottom) {
                    ConfettiOverlay(fireConfetti: $model.fireConfetti)
                }
            }
        }
        .background(Color.Background.primary)
        
        .sheet(item: $model.showTier) { tier in
            tierSelection(tier: tier)
        }
        .anytypeSheet(item: $model.showSuccess) {
            MembershipTierSuccessView(tier: $0)
        }
        .onChange(of: model.emailUrl) { _, url in
            showEmail(url: url)
        }
        .onAppear {
            model.onAppear()
        }
    }
    
    var errorView: some View {
        EmptyStateView(
            title: Loc.Error.Common.title,
            subtitle: Loc.Error.Common.message,
            style: .error,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.tryAgain,
                action: { model.loadTiers() }
            )
        )
    }
    
    
    func tierSelection(tier: MembershipTier) -> some View {
        MembershipTierSelectionCarousel(
            userMembership: model.userMembership,
            allTiers: model.tiers,
            tierToDisplay: tier,
            onSuccessfulPurchase: { tier in
                model.onSuccessfulPurchase(tier: tier)
            }
        )
    }
    
    func showEmail(url: URL?) {
        guard let url = url else { return }
        
        openURL(url) { _ in
            model.emailUrl = nil
        }
    }
}

#Preview {
    NavigationView {
        MembershipCoordinator()
    }
}
