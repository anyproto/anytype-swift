import Services
import Foundation


    
actor MembershipStatusStorageMock: MembershipStatusStorageProtocol {
    nonisolated static let shared = MembershipStatusStorageMock()
    
    nonisolated init() {}
    
    private var _status: MembershipStatus = .empty
    private var _tiers: [MembershipTier] = []

    private var statusContinuations: [UUID: AsyncStream<MembershipStatus>.Continuation] = [:]
    private var tiersContinuations: [UUID: AsyncStream<[MembershipTier]>.Continuation] = [:]

    nonisolated func statusStream() -> AsyncStream<MembershipStatus> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await self.addStatusContinuation(id: id, continuation: continuation)
                continuation.yield(await self._status)
            }

            continuation.onTermination = { _ in
                Task {
                    await self.removeStatusContinuation(id: id)
                }
            }
        }
    }

    func currentStatus() async -> MembershipStatus {
        _status
    }

    nonisolated func tiersStream() -> AsyncStream<[MembershipTier]> {
        AsyncStream { continuation in
            let id = UUID()
            Task {
                await self.addTiersContinuation(id: id, continuation: continuation)
                continuation.yield(await self._tiers)
            }

            continuation.onTermination = { _ in
                Task {
                    await self.removeTiersContinuation(id: id)
                }
            }
        }
    }

    func currentTiers() async -> [MembershipTier] {
        _tiers
    }

    func owningState(tier: Services.MembershipTier) -> MembershipTierOwningState {
        .owned(.purchasedElsewhere(.desktop))
    }

    func startSubscription() async {

    }

    func refreshMembership() async throws {

    }

    func stopSubscriptionAndClean() async {

    }

    nonisolated func setStatus(_ status: MembershipStatus) {
        Task {
            await _setStatus(status)
        }
    }

    private func _setStatus(_ status: MembershipStatus) {
        _status = status
        yieldStatus(status)
    }

    nonisolated func setTiers(_ tiers: [MembershipTier]) {
        Task {
            await _setTiers(tiers)
        }
    }

    private func _setTiers(_ tiers: [MembershipTier]) {
        _tiers = tiers
        yieldTiers(tiers)
    }

    private func addStatusContinuation(id: UUID, continuation: AsyncStream<MembershipStatus>.Continuation) {
        statusContinuations[id] = continuation
    }

    private func removeStatusContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }

    private func addTiersContinuation(id: UUID, continuation: AsyncStream<[MembershipTier]>.Continuation) {
        tiersContinuations[id] = continuation
    }

    private func removeTiersContinuation(id: UUID) {
        tiersContinuations.removeValue(forKey: id)
    }

    private func yieldStatus(_ status: MembershipStatus) {
        for continuation in statusContinuations.values {
            continuation.yield(status)
        }
    }

    private func yieldTiers(_ tiers: [MembershipTier]) {
        for continuation in tiersContinuations.values {
            continuation.yield(tiers)
        }
    }
}
