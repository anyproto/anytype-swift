import Foundation
import Combine
import Services

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    private let spacesSubscriptionService: SpaceManagerSpacesSubscriptionServiceProtocol
    private let participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol
    
    private var spaces: [SpaceView] = []
    private var participants: [Participant] = []
    
    @Published var rows: [SpacesManagerRowViewModel] = []
    
    init(
        spacesSubscriptionService: SpaceManagerSpacesSubscriptionServiceProtocol,
        participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol
    ) {
        self.spacesSubscriptionService = spacesSubscriptionService
        self.participantsSubscriptionByAccountService = participantsSubscriptionByAccountService
    }
    
    func onAppear() async {
        await participantsSubscriptionByAccountService.startSubscription { [weak self] items in
            self?.participants = items
            self?.updateRows()
        }
    }
    
    func startWorkspacesTask() async {
        await spacesSubscriptionService.startSubscription { [weak self] spaces in
            self?.spaces = spaces
            self?.updateRows()
        }
    }
    
    private func updateRows() {
        rows = spaces.map { spaceView in
            let participant = participants.first { $0.spaceId == spaceView.targetSpaceId }
            return SpacesManagerRowViewModel(spaceView: spaceView, participant: participant)
        }
    }
}
