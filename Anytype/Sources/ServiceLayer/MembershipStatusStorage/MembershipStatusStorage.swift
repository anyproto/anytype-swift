import Foundation
import ProtobufMessages
import Combine
import Services

enum MembershipTierOwningState {
    case owned
    case pending
    case unowned
    
    var isOwned: Bool {
        self == .owned
    }
    
    var isPending: Bool {
        self == .pending
    }
}

@MainActor
protocol MembershipStatusStorageProtocol {
    var status: AnyPublisher<MembershipStatus, Never> { get }
    
    func owningState(tier: MembershipTier) async -> MembershipTierOwningState
    
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

@MainActor
final class MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    @Injected(\.storeKitService)
    private var storeKitService: StoreKitServiceProtocol
    
    
    var status: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published var _status: MembershipStatus = .empty
    
    private var subscription: AnyCancellable?
    
    nonisolated init() { }
    
    func owningState(tier: MembershipTier) async -> MembershipTierOwningState {
        if _status.tier?.type == tier.type {
            if _status.status == .active {
                return .owned
            } else {
                return .pending
            }
        }
        
        // validate AppStore purchase in case middleware is still processing
        if case let .appStore(info) = tier.paymentType {
            if ((try? await storeKitService.isPurchased(product: info.product)) ?? false) {
                return .pending
            }
        }
        
        return .unowned
    }
    
    func startSubscription() async {
        _status =  (try? await membershipService.getMembership(noCache: true)) ?? .empty
        await AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
        
        setupSubscription()
    }
    
    func stopSubscriptionAndClean() async {
        subscription = nil
        _status = .empty
        await AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
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
                    _status = try await membershipService.makeMembershipFromMiddlewareModel(membership: update.data)
                    _status.tier.flatMap { AnytypeAnalytics.instance().logChangePlan(tier: $0) }
                    
                    await AnytypeAnalytics.instance().setMembershipTier(tier: _status.tier)
                }
            default:
                break
            }
        }
    }
}
