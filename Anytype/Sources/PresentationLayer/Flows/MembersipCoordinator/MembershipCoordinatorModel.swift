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
    
    init(
        membershipService: MembershipServiceProtocol,
        membershipAssembly: MembershipModuleAssemblyProtocol
    ) {
        self.membershipService = membershipService
        self.membershipAssembly = membershipAssembly
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
    
    func onSuccessfulValidation() {
        emailVerificationData = nil
        showTier = nil
        
        // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
        Task {
            try await Task.sleep(seconds: 0.5)
            showSuccess = .explorer
        }
    }
}
