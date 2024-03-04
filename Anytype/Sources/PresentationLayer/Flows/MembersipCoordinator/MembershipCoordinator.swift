import SwiftUI


struct MembershipCoordinator: View {
    @StateObject var model: MembershipCoordinatorModel
    
    var body: some View {
        model.initialModule()
    }
}

#Preview {
    MembershipCoordinator(
        model: MembershipCoordinatorModel(membershipAssembly: DI.preview.modulesDI.membership())
    )
}
