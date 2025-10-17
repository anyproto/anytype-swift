import SwiftUI
import Services
import AnytypeCore


@MainActor
final class MembershipCoordinatorModel: ObservableObject {
    @Published var userMembership: MembershipStatus = .empty
    @Published private var allTiers: [MembershipTier] = []

    @Published var showTiersLoadingError = false
    @Published var showTier: MembershipTier?
    @Published var showSuccess: MembershipTier?
    @Published var fireConfetti = false
    @Published var emailUrl: URL?

    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol

    private let initialTierId: Int?

    var tiers: [MembershipTier] {
        let currentTierId = userMembership.tier?.type.id ?? 0
        return allTiers
            .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
            .filter { !$0.iosProductID.isEmpty || $0.type.id == currentTierId }
    }

    init(initialTierId: Int?) {
        self.initialTierId = initialTierId
        membershipStatusStorage.statusPublisher.receiveOnMain().assign(to: &$userMembership)
        membershipStatusStorage.tiersPublisher.receiveOnMain().assign(to: &$allTiers)
    }
    
    func onAppear() {
        Task {
            guard let initialTierId else { return }
            guard let initialTier = tiers.first(where: { $0.type.id == initialTierId }) else {
                anytypeAssertionFailure("Not found initial id for Memberhsip coordinator", info: ["tierId": String(initialTierId)])
                return
            }
            onTierSelected(tier: initialTier)
        }
    }

    func retryLoadTiers() {
        Task {
            await membershipStatusStorage.refreshMembership()
            showTiersLoadingError = false
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

        Task {
            await membershipStatusStorage.refreshMembership()

            // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
            try await Task.sleep(seconds: 0.5)
            showSuccess = tier

            try await Task.sleep(seconds: 0.5)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            fireConfetti = true
        }
    }
}
