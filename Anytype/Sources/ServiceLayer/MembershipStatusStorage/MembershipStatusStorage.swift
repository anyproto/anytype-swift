import Foundation
import ProtobufMessages
import Combine
import Services

@MainActor
protocol MembershipStatusStorageProtocol {
    var status: Published<MembershipStatus>.Publisher { get }
}

@MainActor
final class MembershipStatusStorage: MembershipStatusStorageProtocol {
    @Injected(\.membershipService)
    private var membershipService: MembershipServiceProtocol
    
    var status: Published<MembershipStatus>.Publisher { $_status }
    @Published var _status: MembershipStatus = .empty
    
    private var subscription: AnyCancellable?
    
    nonisolated init() {
        Task {
            try await setupInitialState()
        }
    }
    
    // MARK: - Private
        
    private func setupInitialState() async throws {
        _status = try await membershipService.getStatus()
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
                _status = update.data.asModel()
            default:
                break
            }
        }
    }
}
