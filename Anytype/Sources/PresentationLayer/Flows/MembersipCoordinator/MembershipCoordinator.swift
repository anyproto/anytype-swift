import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    var body: some View {
        model.initialModule()
            .sheet(item: $model.showTier) {
                model.tierSelection(tier: $0)
                    .sheet(isPresented: $model.showEmailVerification) {
                        model.emailVerification()
                    }
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
