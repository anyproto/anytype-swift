import Foundation

@MainActor
final class SpaceShareViewModel: ObservableObject {
    
    private let participantSubscriptionService: ParticipantsSubscriptionServiceProtocol
    
    @Published var participants: [Participant] = []
    
    init(participantSubscriptionService: ParticipantsSubscriptionServiceProtocol) {
        self.participantSubscriptionService = participantSubscriptionService
        startSubscriptions()
    }
    
    private func startSubscriptions() {
        Task {
            await participantSubscriptionService.startSubscription { [weak self] items in
                self?.participants = items
            }
        }
    }
    
    deinit {
        Task { [participantSubscriptionService] in
            await participantSubscriptionService.stopSubscription()
        }
    }
}
