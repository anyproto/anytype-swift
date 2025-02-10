import Foundation
import ProtobufMessages
import Combine
import Services


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
    
    private var subscription: AnyCancellable?
    
    nonisolated init() { }
    
    func startSubscription() async {
        _status =  (try? await membershipService.getMembership(noCache: true)) ?? .empty
        AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
        
        setupSubscription()
    }
    
    func stopSubscriptionAndClean() async {
        subscription = nil
        _status = .empty
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
                    let allTiers = try await membershipService.getTiers()
                    
                    _status = try builder.buildMembershipStatus(membership: update.data, allTiers: allTiers)
                    _status.tier.flatMap { AnytypeAnalytics.instance().logChangePlan(tier: $0) }
                    
                    AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
                }
            default:
                break
            }
        }
    }
}
