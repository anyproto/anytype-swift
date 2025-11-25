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
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }
    
    // MARK: - Private
    
    private func setupSubscription() {        
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            Task { @MainActor [weak self] in
                self?.handle(events: events)
            }
        }
    }
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .membershipUpdate(let update):
                handleMembershipUpdate(update)
            case .membershipTiersUpdate(let update):
                handleMembershipTiersUpdate(update)
            default:
                break
            }
        }
    }

    private func handleMembershipUpdate(_ update: Anytype_Event.Membership.Update) {
        Task {
            _currentMembership = update.data

            rebuildStatusIfReady()

            if let tier = _cachedTiers.first(where: { $0.id.id == update.data.tier }) {
                AnytypeAnalytics.instance().logChangePlan(tier: tier)
            }
        }
    }

    private func handleMembershipTiersUpdate(_ update: Anytype_Event.Membership.TiersUpdate) {
        Task {
            let filteredTiers = update.tiers
                .filter { FeatureFlags.membershipTestTiers || !$0.isTest }

            _cachedTiers = await filteredTiers.asyncMap { await builder.buildMembershipTier(tier: $0) }.compactMap { $0 }

            rebuildStatusIfReady()
        }
    }

    private func rebuildStatusIfReady() {
        guard let membership = _currentMembership, !_cachedTiers.isEmpty else { return }

        guard let newStatus = try? builder.buildMembershipStatus(membership: membership, allTiers: _cachedTiers) else {
            return
        }

        _status = newStatus
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }
}
