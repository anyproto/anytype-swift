import Foundation
import Combine
import Services

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private let participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol
    
    private var spaces: [SpaceView] = []
    private var participants: [Participant] = []
    
    @Published var rows: [SpacesManagerRowViewModel] = []
    
    init(workspacesStorage: WorkspacesStorageProtocol, participantsSubscriptionByAccountService: ParticipantsSubscriptionByAccountServiceProtocol) {
        self.workspacesStorage = workspacesStorage
        self.participantsSubscriptionByAccountService = participantsSubscriptionByAccountService
    }
    
    func onAppear() async {
        await participantsSubscriptionByAccountService.startSubscription { [weak self] items in
            self?.participants = items
            self?.updateRows()
        }
    }
    
    func startWorkspacesTask() async {
        for await spaces in workspacesStorage.workspsacesPublisher.values {
            self.spaces = spaces.sorted { $0.createdDate ?? Date() < $1.createdDate ?? Date() }
            updateRows()
        }
    }
    
    private func updateRows() {
        rows = spaces.map { spaceView in
            let participant = participants.first { $0.spaceId == spaceView.targetSpaceId }
            return SpacesManagerRowViewModel(spaceView: spaceView, participant: participant)
        }
    }
}
