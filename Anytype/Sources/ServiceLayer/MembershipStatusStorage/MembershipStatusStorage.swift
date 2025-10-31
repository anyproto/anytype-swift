import Foundation
import ProtobufMessages
import Combine
import Services
import AnytypeCore


protocol MembershipStatusStorageProtocol: Sendable, Actor {
    nonisolated func statusStream() -> AsyncStream<MembershipStatus>
    func currentStatus() async -> MembershipStatus
    nonisolated func tiersStream() -> AsyncStream<[MembershipTier]>
    func currentTiers() async -> [MembershipTier]

    func startSubscription() async
    func stopSubscriptionAndClean() async
    func refreshMembership() async throws
}

actor MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.membershipModelBuilder)
    private var builder: any MembershipModelBuilderProtocol

    private var _status: MembershipStatus = .empty
    private var _tiers: [MembershipTier] = []

    private var statusContinuations: [UUID: AsyncStream<MembershipStatus>.Continuation] = [:]
    private var tiersContinuations: [UUID: AsyncStream<[MembershipTier]>.Continuation] = [:]

    private var subscription: AnyCancellable?
    private var tiersUpdateTask: Task<Void, Never>?
    private var membershipUpdateTask: Task<Void, Never>?

    nonisolated init() { }

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
    
    func startSubscription() async {
        _status = (try? await membershipService.getMembership(noCache: false)) ?? .empty
        _tiers = (try? await membershipService.getTiers(noCache: false)) ?? []
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)

        yieldStatus(_status)
        yieldTiers(_tiers)

        setupSubscription()
    }

    func stopSubscriptionAndClean() async {
        subscription = nil
        tiersUpdateTask?.cancel()
        tiersUpdateTask = nil
        membershipUpdateTask?.cancel()
        membershipUpdateTask = nil
        _status = .empty
        _tiers = []

        yieldStatus(_status)
        yieldTiers(_tiers)

        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }

    func refreshMembership() async throws {
        _status = try await membershipService.getMembership(noCache: true)
        _tiers = try await membershipService.getTiers(noCache: true)

        yieldStatus(_status)
        yieldTiers(_tiers)

        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }

    // MARK: - Private

    private func setupSubscription() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .membershipUpdate(let update):
                membershipUpdateTask?.cancel()
                membershipUpdateTask = Task { [weak self, builder] in
                    guard let self else { return }
                    guard await !self._tiers.isEmpty else {
                        return
                    }

                    if Task.isCancelled { return }

                    do {
                        let status = try await builder.buildMembershipStatus(
                            membership: update.data,
                            allTiers: await self._tiers
                        )

                        if Task.isCancelled { return }

                        await self.updateStatus(status)
                        status.tier.flatMap { AnytypeAnalytics.instance().logChangePlan(tier: $0) }
                        AnytypeAnalytics.instance().setMembershipTier(tier: status.tier)
                    } catch {
                        print("[Membership] Failed to build status: \(error)")
                    }
                }

            case .membershipTiersUpdate(let update):
                tiersUpdateTask?.cancel()
                tiersUpdateTask = Task { [weak self, builder] in
                    var built: [MembershipTier] = []
                    for tier in update.tiers {
                        if Task.isCancelled { return }
                        if let builtTier = await builder.buildMembershipTier(tier: tier) {
                            built.append(builtTier)
                        }
                    }

                    if Task.isCancelled { return }

                    await self?.updateTiers(built)
                }

            default:
                break
            }
        }
    }

    private func updateStatus(_ status: MembershipStatus) {
        _status = status
        yieldStatus(status)
    }

    private func updateTiers(_ tiers: [MembershipTier]) {
        _tiers = tiers
        yieldTiers(tiers)
    }
}
