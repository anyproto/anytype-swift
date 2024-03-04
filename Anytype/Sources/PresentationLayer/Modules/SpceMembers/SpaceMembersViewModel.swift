import Foundation
import Services

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let participantSubscriptionService: ParticipantsSubscriptionBySpaceServiceProtocol
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    init(participantSubscriptionService: ParticipantsSubscriptionBySpaceServiceProtocol) {
        self.participantSubscriptionService = participantSubscriptionService
    }
    
    func onAppear() async {
        await participantSubscriptionService.startSubscription(onlyActive: false) { [weak self] items in
            self?.updateParticipant(items: items)
        }
    }
    
    private func updateParticipant(items: [Participant]) {
        rows = items.map { participant in
            SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: participant.name,
                status: .active(permission: participant.permission.title),
                action: nil,
                contextActions: []
            )
        }
    }
}
