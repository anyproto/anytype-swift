import SwiftUI


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var showTier: MembershipTier?
    @Published var showEmailVerification = false
    
    private let membershipAssembly: MembershipModuleAssemblyProtocol
    private let tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol
    private let emailVerificationAssembly: EmailVerificationAssemblyProtocol
    
    init(
        membershipAssembly: MembershipModuleAssemblyProtocol,
        tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol,
        emailVerificationAssembly: EmailVerificationAssemblyProtocol
    ) {
        self.membershipAssembly = membershipAssembly
        self.tierSelectionAssembly = tierSelectionAssembly
        self.emailVerificationAssembly = emailVerificationAssembly
    }
    
    func initialModule() -> AnyView {
        membershipAssembly.make { [weak self] tier in
            self?.showTier = tier
        }
    }
    
    func tierSelection(tier: MembershipTier) -> AnyView {
        tierSelectionAssembly.make(tier: tier) { [weak self] in
            self?.showEmailVerification = true
        }
    }
    
    func emailVerification() -> AnyView {
        emailVerificationAssembly.make { [weak self] in
            self?.showEmailVerification = false
            self?.showTier = nil
        }
    }
}
