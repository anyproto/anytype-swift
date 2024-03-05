import SwiftUI

protocol MembershipTierSelectionAssemblyProtocol {
    func make(tier: MembershipTier) -> AnyView
}

final class MembershipTierSelectionAssembly: MembershipTierSelectionAssemblyProtocol {
    let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(tier: MembershipTier) -> AnyView {
        MembershipTierSelectionView(
            model: MembershipTierSelectionViewModel(
                tier: tier,
                membershipService: serviceLocator.membershipService()
            )
        ).eraseToAnyView()
    }
}
