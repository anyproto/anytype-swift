import SwiftUI
import Services
import AnytypeCore


@MainActor
@Observable
final class MembershipCoordinatorModel {
    var userMembership: MembershipStatus = .empty
    var tiers: [MembershipTier] = []

    var showTiersLoadingError = false
    var showTier: MembershipTier?
    var showSuccess: MembershipTier?
    var fireConfetti = false
    var emailUrl: URL?

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @ObservationIgnored @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol

    @ObservationIgnored
    private let initialTierId: Int?

    init(initialTierId: Int?) {
        self.initialTierId = initialTierId
    }

    func startMembershipSubscription() async {
        for await status in membershipStatusStorage.statusPublisher.values {
            userMembership = status
        }
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
