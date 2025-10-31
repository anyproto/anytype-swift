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
    
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private let initialTierId: Int?
    private var statusTask: Task<Void, Never>?
    private var tiersTask: Task<Void, Never>?

    init(initialTierId: Int?) {
        self.initialTierId = initialTierId

        statusTask = Task { [weak self] in
            guard let self else { return }
            for await status in membershipStatusStorage.statusStream() {
                self.userMembership = status
            }
        }

        tiersTask = Task { [weak self] in
            guard let self else { return }
            for await (status, allTiers) in self.combinedStream() {
                let currentTierId = status.tier?.type.id ?? 0
                self.tiers = allTiers
                    .filter { FeatureFlags.membershipTestTiers || !$0.isTest }
                    .filter { !$0.iosProductID.isEmpty || $0.type.id == currentTierId }
            }
        }
    }

    deinit {
        statusTask?.cancel()
        tiersTask?.cancel()
    }

    private func combinedStream() -> AsyncStream<(MembershipStatus, [MembershipTier])> {
        let storage = membershipStatusStorage
        return AsyncStream { continuation in
            let task = Task {
                var currentStatus = await storage.currentStatus()
                var currentTiers = await storage.currentTiers()

                continuation.yield((currentStatus, currentTiers))

                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        for await status in storage.statusStream() {
                            currentStatus = status
                            continuation.yield((currentStatus, currentTiers))
                        }
                    }

                    group.addTask {
                        for await tiers in storage.tiersStream() {
                            currentTiers = tiers
                            continuation.yield((currentStatus, currentTiers))
                        }
                    }
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
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
            do {
                try await membershipStatusStorage.refreshMembership()
                showTiersLoadingError = false
            } catch {
                showTiersLoadingError = true
            }
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
            try? await membershipStatusStorage.refreshMembership()

            // https://linear.app/anytype/issue/IOS-2434/bottom-sheet-nesting
            try await Task.sleep(seconds: 0.5)
            showSuccess = tier
            
            try await Task.sleep(seconds: 0.5)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            fireConfetti = true
        }
    }
}
