import Foundation
import Services


@MainActor
final class MembershipModuleViewModel: ObservableObject {
    @Published var tier: MembershipTier?
    
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    private let onTierTap: (MembershipTier) -> ()
    
    init(onTierTap: @escaping (MembershipTier) -> ()) {
        self.onTierTap = onTierTap
    }
    
    func updateCurrentTier() {
        Task {
            tier = try await membershipService.getStatus()
        }
    }
    
    func onTierTap(tier: MembershipTier) {
        onTierTap(tier)
    }
}
