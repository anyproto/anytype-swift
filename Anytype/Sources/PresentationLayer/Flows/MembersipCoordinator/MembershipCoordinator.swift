import SwiftUI
import Services


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    @Environment(\.openURL) private var openURL
    
    init() {
        _model = StateObject(wrappedValue: MembershipCoordinatorModel())
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
            }
        }
        .animation(.default, value: model.userMembership)
        
        
        .sheet(item: $model.showTier) { tier in
            tierSelection(tier: tier)
        }
        .anytypeSheet(item: $model.showSuccess) {
            MembershipTierSuccessView(tier: $0)
        }
        .onChange(of: model.emailUrl) { url in
            showEmail(url: url)
        }
    }
    
    var errorView: some View {
        EmptyStateView(
            title: Loc.Error.Common.title,
            subtitle: Loc.Error.Common.message,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.Error.Common.tryAgain,
                action: { model.loadTiers() }
            )
        )
    }
    
    
    func tierSelection(tier: MembershipTier) -> some View {
        MembershipTierSelectionCarousel(
            userMembership: model.userMembership,
            allTiers: model.tiers,
            tierToDisplay: tier,
            showEmailVerification: { data in
                model.onEmailDataSubmit(data: data)
            },
            onSuccessfulPurchase: { tier in
                model.onSuccessfulPurchase(tier: tier)
            }
        )
        .sheet(item: $model.emailVerificationData) { data in
            EmailVerificationView(data: data) {
                model.onSuccessfulValidation(data: data)
            }
        }
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
