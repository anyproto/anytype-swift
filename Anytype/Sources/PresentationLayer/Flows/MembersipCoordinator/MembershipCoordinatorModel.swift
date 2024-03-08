import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    
    @Published var userTier: MembershipTier?
    
    private let membershipService: MembershipServiceProtocol
    
    private let membershipAssembly: MembershipModuleAssemblyProtocol
    private let tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol
    private let emailVerificationAssembly: EmailVerificationAssemblyProtocol
    
    init(
        membershipService: MembershipServiceProtocol,
        membershipAssembly: MembershipModuleAssemblyProtocol,
        tierSelectionAssembly: MembershipTierSelectionAssemblyProtocol,
        emailVerificationAssembly: EmailVerificationAssemblyProtocol
    ) {
        self.membershipService = membershipService
        self.membershipAssembly = membershipAssembly
        self.tierSelectionAssembly = tierSelectionAssembly
        self.emailVerificationAssembly = emailVerificationAssembly
    }
    
    func onAppear() {
        Task {
            userTier = try await membershipService.getStatus()
        }
    }
    
    func initialModule() -> AnyView {
        membershipAssembly.make { [weak self] tier in
            self?.showTier = tier
        }
    }
    
    func tierSelection(tier: MembershipTier) -> AnyView {
        tierSelectionAssembly.make(tier: tier) { [weak self] data in
            self?.emailVerificationData = data
        }
    }
    
    func emailVerification(data: EmailVerificationData) -> AnyView {
        emailVerificationAssembly.make(data: data) { [weak self] in
            self?.emailVerificationData = nil
            self?.showTier = nil
            
            // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
            Task {
                try await Task.sleep(seconds: 0.5)
                self?.showSuccess = .explorer
            }
        }
    }
}
