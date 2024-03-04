import SwiftUI


@MainActor
protocol MembershipCoordinatorAssemblyProtocol {
    func make() -> AnyView
}

final class MembershipCoordinatorAssembly: MembershipCoordinatorAssemblyProtocol {
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    func make() -> AnyView {
        MembershipCoordinator(
            model: MembershipCoordinatorModel(
                membershipAssembly: self.modulesDI.membership()
            )
        ).eraseToAnyView()
    }
}
