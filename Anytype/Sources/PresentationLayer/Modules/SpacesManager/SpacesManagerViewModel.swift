import Foundation
import Combine

@MainActor
final class SpacesManagerViewModel: ObservableObject {
    
    private let workspacesStorage: WorkspacesStorageProtocol
    private let participantsSubscriptionServiceByAccount: ParticipantsSubscriptionServiceByAccountProtocol
    
    private var spaces: [SpaceView] = []
    private var participants: [Participant] = []
    
    @Published var rows: [SpacesManagerRowViewModel] = []
    
    init(workspacesStorage: WorkspacesStorageProtocol, participantsSubscriptionServiceByAccount: ParticipantsSubscriptionServiceByAccountProtocol) {
        self.workspacesStorage = workspacesStorage
        self.participantsSubscriptionServiceByAccount = participantsSubscriptionServiceByAccount
    }
    
    func onAppear() async {
        await participantsSubscriptionServiceByAccount.startSubscription { [weak self] items in
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
            return SpacesManagerRowViewModel(
                id: spaceView.id,
                name: spaceView.name,
                iconImage: spaceView.iconImage,
                accountStatus: spaceView.accountStatus?.name ?? "",
                localStatus: spaceView.localStatus?.name ?? "",
                permission: participant?.permission.title ?? ""
            )
        }
    }
}
