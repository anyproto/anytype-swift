import Foundation
import ProtobufMessages
import Combine
import Services
import AnytypeCore


@MainActor
protocol MembershipStatusStorageProtocol: Sendable {
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { get }
    var currentStatus: MembershipStatus { get }
    
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

@MainActor
final class MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.membershipModelBuilder)
    private var builder: any MembershipModelBuilderProtocol
    
    
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: MembershipStatus { _status }
    @Published private var _status: MembershipStatus = .empty

    private var _currentMembership: Anytype_Model_Membership?
    private var _cachedTiers: [MembershipTier] = []
    private var _pendingPlanChangeTierId: Int?

    private var subscription: AnyCancellable?
    
    nonisolated init() { }
    
    func startSubscription() async {
        _status =  (try? await membershipService.getMembership(noCache: false)) ?? .empty
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)

        setupSubscription()
    }
    
    func stopSubscriptionAndClean() async {
        subscription = nil
        _status = .empty
        _currentMembership = nil
        _cachedTiers = []
        _pendingPlanChangeTierId = nil
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }
    
    // MARK: - Private
    
    private func setupSubscription() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            Task { @MainActor [weak self] in
                await self?.handle(events: events)
            }
        }
    }
    
    private func handle(events: EventsBunch) async {
        for event in events.middlewareEvents {
            switch event.value {
            case .membershipUpdate(let update):
                await handleMembershipUpdate(update)
            case .membershipTiersUpdate(let update):
                await handleMembershipTiersUpdate(update)
            default:
                break
            }
        }
    }

    private func handleMembershipUpdate(_ update: Anytype_Event.Membership.Update) async {
        _currentMembership = update.data
        _pendingPlanChangeTierId = Int(update.data.tier)

        rebuildStatusIfReady()
    }

    private func handleMembershipTiersUpdate(_ update: Anytype_Event.Membership.TiersUpdate) async {
        let filteredTiers = update.tiers
            .filter { FeatureFlags.membershipTestTiers || !$0.isTest }

        _cachedTiers = await filteredTiers.asyncMap { await builder.buildMembershipTier(tier: $0) }.compactMap { $0 }

        rebuildStatusIfReady()
    }

    private func rebuildStatusIfReady() {
        guard let membership = _currentMembership, !_cachedTiers.isEmpty else { return }

        guard let newStatus = try? builder.buildMembershipStatus(membership: membership, allTiers: _cachedTiers) else {
            return
        }

        _status = newStatus
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)

        if let pendingTierId = _pendingPlanChangeTierId,
           let tier = _cachedTiers.first(where: { $0.id.id == pendingTierId }) {
            AnytypeAnalytics.instance().logChangePlan(tier: tier)
            _pendingPlanChangeTierId = nil
        }
    }
}
