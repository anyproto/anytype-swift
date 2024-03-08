import SwiftUI


@MainActor
protocol MembershipCoordinatorAssemblyProtocol {
    func make() -> AnyView
}

final class MembershipCoordinatorAssembly: MembershipCoordinatorAssemblyProtocol {
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    
    nonisolated init(modulesDI: ModulesDIProtocol, serviceLocator: ServiceLocator) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
    }
    
    func make() -> AnyView {
        MembershipCoordinator(
            model: MembershipCoordinatorModel(
                membershipService: self.serviceLocator.membershipService(),
                membershipAssembly: self.modulesDI.membership(),
                tierSelectionAssembly: self.modulesDI.membershipTierSelection(), 
                emailVerificationAssembly: self.modulesDI.emailVerification()
            )
        ).eraseToAnyView()
    }
}
