import SwiftUI
import Services


@MainActor
protocol MembershipTierSelectionAssemblyProtocol {
    func make(tier: MembershipTier, showEmailVerification: @escaping (EmailVerificationData) -> ()) -> AnyView
}

final class MembershipTierSelectionAssembly: MembershipTierSelectionAssemblyProtocol {
    let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(tier: MembershipTier, showEmailVerification: @escaping (EmailVerificationData) -> ()) -> AnyView {
        MembershipTierSelectionView(
            model: MembershipTierSelectionViewModel(
                tierToDisplay: tier,
                membershipService: self.serviceLocator.membershipService(),
                showEmailVerification: showEmailVerification
            )
        ).eraseToAnyView()
    }
}
