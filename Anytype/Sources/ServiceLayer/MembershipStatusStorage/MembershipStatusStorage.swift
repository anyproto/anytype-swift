import Foundation
import ProtobufMessages
import Combine
import Services

@MainActor
protocol MembershipStatusStorageProtocol {
    var status: AnyPublisher<MembershipStatus, Never> { get }
}

@MainActor
final class MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    var status: AnyPublisher<MembershipStatus, Never> { $_status.eraseToAnyPublisher() }
    @Published var _status: MembershipStatus = .empty
    
    private var subscription: AnyCancellable?
    
    nonisolated init() {
        Task {
            try await setupInitialState()
        }
    }
    
    // MARK: - Private
        
    private func setupInitialState() async throws {
        _status = try await membershipService.getMembership()
        setupSubscription()
    }
    
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
                }
            default:
                break
            }
        }
    }
}
