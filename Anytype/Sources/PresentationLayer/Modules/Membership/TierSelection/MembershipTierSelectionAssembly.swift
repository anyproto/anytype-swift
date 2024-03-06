import SwiftUI


@MainActor
protocol MembershipTierSelectionAssemblyProtocol {
    func make(tier: MembershipTier, showEmailVerification: @escaping () -> ()) -> AnyView
}

final class MembershipTierSelectionAssembly: MembershipTierSelectionAssemblyProtocol {
    let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(tier: MembershipTier, showEmailVerification: @escaping () -> ()) -> AnyView {
        MembershipTierSelectionView(
            model: MembershipTierSelectionViewModel(
                tier: tier,
                membershipService: serviceLocator.membershipService(),
                showEmailVerification: showEmailVerification
            )
        ).eraseToAnyView()
    }
}
