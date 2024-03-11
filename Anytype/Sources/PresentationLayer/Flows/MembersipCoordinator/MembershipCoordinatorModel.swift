import SwiftUI
import Services


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var emailVerificationData: EmailVerificationData?
    
    @Published var userTier: MembershipTier?
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    func onAppear() {
        Task {
            userTier = try await membershipService.getStatus()
        }
    }
    
    func onSuccessfulTierSelection(data: EmailVerificationData) {
        emailVerificationData = data
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
