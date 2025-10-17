import Foundation
import ProtobufMessages
import Combine
import Services
import AnytypeCore


@MainActor
protocol MembershipStatusStorageProtocol: Sendable {
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { get }
    var currentStatus: MembershipStatus { get }
    var tiersPublisher: AnyPublisher<[MembershipTier], Never> { get }
    var currentTiers: [MembershipTier] { get }

    func startSubscription() async
    func stopSubscriptionAndClean() async
    func refreshMembership() async
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

    var tiersPublisher: AnyPublisher<[MembershipTier], Never> { $_tiers.eraseToAnyPublisher() }
    var currentTiers: [MembershipTier] { _tiers }
    @Published private var _tiers: [MembershipTier] = []

    private var subscription: AnyCancellable?

    nonisolated init() { }
    
    func startSubscription() async {
        _status = (try? await membershipService.getMembership(noCache: false)) ?? .empty
        _tiers = (try? await membershipService.getTiers(noCache: false)) ?? []
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)

        setupSubscription()
    }
    
    func stopSubscriptionAndClean() async {
        subscription = nil
        _status = .empty
        _tiers = []
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
    }

    func refreshMembership() async {
        _status = (try? await membershipService.getMembership(noCache: true)) ?? _status
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
                Task {
                    guard !_tiers.isEmpty else {
                        print("[Membership] Skipping membershipUpdate - no tiers available yet")
                        return
                    }

                    do {
                        _status = try builder.buildMembershipStatus(
                            membership: update.data,
                            allTiers: _tiers
                        )
                        _status.tier.flatMap { AnytypeAnalytics.instance().logChangePlan(tier: $0) }
                        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
                        print("[Membership] Updated membership status - tier: \(_status.tier?.name ?? "none")")
                    } catch {
                        print("[Membership] Failed to build status: \(error)")
                    }
                }

            case .membershipTiersUpdate(let update):
                Task {
                    var built: [MembershipTier] = []
                    for tier in update.tiers {
                        if let builtTier = await builder.buildMembershipTier(tier: tier) {
                            built.append(builtTier)
                        }
                    }
                    _tiers = built
                }

            default:
                break
            }
        }
    }
}
