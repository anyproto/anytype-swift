import SwiftUI


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var showTier: MembershipTier?
    
    private let membershipAssembly: MembershipModuleAssemblyProtocol
    
    init(membershipAssembly: MembershipModuleAssemblyProtocol) {
        self.membershipAssembly = membershipAssembly
    }
    
    func initialModule() -> AnyView {
        membershipAssembly.make { [weak self] tier in
            self?.showTier = tier
        }
    }
    
    func tierSelection(tier: MembershipTier) -> AnyView {
        MembershipTierSelectionView(tier: tier).eraseToAnyView()
    }
}
