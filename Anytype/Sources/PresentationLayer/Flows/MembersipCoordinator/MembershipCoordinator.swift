import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    var body: some View {
        model.initialModule()
            .sheet(item: $model.showTier) { tier in
                MembershipTierSelectionView(tier: tier) { data in
                    model.emailVerificationData = data
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
        MembershipCoordinator(
            model: MembershipCoordinatorModel(
                membershipService: DI.preview.serviceLocator.membershipService(),
                membershipAssembly: DI.preview.modulesDI.membership()
            )
        )
    }
}
