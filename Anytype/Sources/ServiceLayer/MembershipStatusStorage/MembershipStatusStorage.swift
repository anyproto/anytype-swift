import Foundation
import ProtobufMessages
import Combine
import Services


@MainActor
protocol MembershipStatusStorageProtocol: Sendable {
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { get }
    var currentStatus: MembershipStatus { get }
    var tiersPublisher: AnyPublisher<[MembershipTier], Never> { get }
    var currentTiers: [MembershipTier] { get }

    func startSubscription() async
    func stopSubscriptionAndClean() async
}

@MainActor
final class MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    @Injected(\.membershipModelBuilder)
    private var builder: any MembershipModelBuilderProtocol

    nonisolated init() { }
    var statusPublisher: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: MembershipStatus { _status }
    @Published private var _status: MembershipStatus = .empty

    var tiersPublisher: AnyPublisher<[MembershipTier], Never> { $_tiers.eraseToAnyPublisher() }
    var currentTiers: [MembershipTier] { _tiers }
    @Published private var _tiers: [MembershipTier] = []

    private var currentMembershipData: Anytype_Model_Membership?
    private var subscription: AnyCancellable?

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
        currentMembershipData = nil
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
                    currentMembershipData = update.data
                    _tiers = try await membershipService.getTiers()

                    _status = try builder.buildMembershipStatus(membership: update.data, allTiers: _tiers)
                    _status.tier.flatMap { AnytypeAnalytics.instance().logChangePlan(tier: $0) }

                    AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)

                }
            case .membershipTiersUpdate:
                Task {
                    _tiers = try await membershipService.getTiers()

                    if let currentMembershipData {
                        _status = try builder.buildMembershipStatus(membership: currentMembershipData, allTiers: _tiers)
                    }

                }
            default:
                break
            }
        }
    }
}
