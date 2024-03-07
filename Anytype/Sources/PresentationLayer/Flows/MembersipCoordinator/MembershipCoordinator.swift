import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    var body: some View {
        model.initialModule()
            .sheet(item: $model.showTier) {
                model.tierSelection(tier: $0)
                    .sheet(item: $model.emailVerificationData) {
                        model.emailVerification(data: $0)
                    }
            }
        
            .anytypeSheet(item: $model.showSuccess) {
                MembershipTierSuccessView(tier: $0)
            }
    }
}

#Preview {
    MembershipCoordinator(
        model: MembershipCoordinatorModel(
            membershipAssembly: DI.preview.modulesDI.membership(),
            tierSelectionAssembly: DI.preview.modulesDI.membershipTierSelection(),
            emailVerificationAssembly: DI.preview.modulesDI.emailVerification()
        )
    )
}
