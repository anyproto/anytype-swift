import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    init() {
        _model = StateObject(wrappedValue: MembershipCoordinatorModel())
    }
    
    var body: some View {
        MembershipModuleView(userTierPublisher: model.$userTier.eraseToAnyPublisher()) { tier in
            model.onTierSelected(tier: tier)
        }
        .animation(.default, value: model.userTier)
        
        .sheet(item: $model.showTier) { tier in
            MembershipTierSelectionView(userTier: model.userTier, tierToDisplay: tier) { data in
                model.onEmailDataSubmit(data: data)
            }
            .sheet(item: $model.emailVerificationData) { data in
                EmailVerificationView(data: data) {
                    model.onSuccessfulValidation()
                }
            }
        }
    
        .anytypeSheet(item: $model.showSuccess) {
            MembershipTierSuccessView(tier: $0)
        }
        .task {
            model.onAppear()
        }
    }
}

#Preview {
    NavigationView {
        MembershipCoordinator()
    }
}
