import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    init() {
        _model = StateObject(wrappedValue: MembershipCoordinatorModel())
    }
    
    var body: some View {
        MembershipModuleView { tier in
            model.showTier = tier
        }
        .sheet(item: $model.showTier) { tier in
            MembershipTierSelectionView(tier: tier) { data in
                model.onSuccessfulTierSelection(data: data)
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
