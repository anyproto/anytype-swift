import SwiftUI
import Services


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    @Environment(\.openURL) private var openURL
    
    init() {
        _model = StateObject(wrappedValue: MembershipCoordinatorModel())
    }
    
    var body: some View {
        MembershipModuleView(userTierPublisher: model.$userTier.eraseToAnyPublisher()) { tier in
            model.onTierSelected(tier: tier)
        }
        .animation(.default, value: model.userTier)
        
        
        .sheet(item: $model.showTier) { tier in
            tierSelection(tier: tier)
        }
        .anytypeSheet(item: $model.showSuccess) {
            MembershipTierSuccessView(tier: $0)
        }
        .onChange(of: model.emailUrl) { url in
            showEmail(url: url)
        }
        
        
        .task {
            model.onAppear()
        }
    }
    
    func tierSelection(tier: MembershipTier) -> some View {
        MembershipTierSelectionView(userTier: model.userTier, tierToDisplay: tier) { data in
            model.onEmailDataSubmit(data: data)
        }
        .sheet(item: $model.emailVerificationData) { data in
            EmailVerificationView(data: data) {
                model.onSuccessfulValidation()
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
