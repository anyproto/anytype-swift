import SwiftUI
import Services
import AnytypeCore


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    @Published var tiers: [MembershipTier] = []
    
    @Published var showTiersLoadingError = false
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var fireConfetti = false
    @Published var emailUrl: URL?
    
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private let initialTierId: Int?
    
    init(initialTierId: Int?) {
        self.initialTierId = initialTierId
        membershipStatusStorage.statusPublisher.receiveOnMain().assign(to: &$userMembership)
        membershipStatusStorage.tiersPublisher.receiveOnMain().assign(to: &$tiers)
    }
    
    func onAppear() {
        Task {
            await loadTiers()
            
            guard let initialTierId else { return }
            guard let initialTier = tiers.first(where: { $0.type.id == initialTierId }) else {
                anytypeAssertionFailure("Not found initial id for Memberhsip coordinator", info: ["tierId": String(initialTierId)])
                return
            }
            onTierSelected(tier: initialTier)
        }
    }
    
    func loadTiers(noCache: Bool = false) {
        Task { await loadTiers(noCache: noCache) }
    }
    
    private func loadTiers(noCache: Bool = false) async {
        do {
            tiers = try await membershipService.getTiers(noCache: noCache)
            showTiersLoadingError = false
        } catch {
            showTiersLoadingError = true
        }
    }
    
    func onTierSelected(tier: MembershipTier) {
        showTier = tier
    }
    
    func onSuccessfulPurchase(tier: MembershipTier) {
        showSuccessScreen(tier: tier)
    }
    
    private func showSuccessScreen(tier: MembershipTier) {
        showTier = nil
        loadTiers(noCache: true)
        
        Task {
            // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
            try await Task.sleep(seconds: 0.5)
            showSuccess = tier
            
            try await Task.sleep(seconds:0.5)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            fireConfetti = true
        }
    }
}
