import SwiftUI


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var showTier: MembershipTier?
    
    private let membershipAssembly: MembershipModuleAssemblyProtocol
    private let tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol
    
    init(
        membershipAssembly: MembershipModuleAssemblyProtocol,
        tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol
    ) {
        self.membershipAssembly = membershipAssembly
        self.tierSelectionAssembly = tierSelectionAssembly
    }
    
    func initialModule() -> AnyView {
        membershipAssembly.make { [weak self] tier in
            self?.showTier = tier
        }
    }
    
    func tierSelection(tier: MembershipTier) -> AnyView {
        tierSelectionAssembly.make(tier: tier)
    }
}
