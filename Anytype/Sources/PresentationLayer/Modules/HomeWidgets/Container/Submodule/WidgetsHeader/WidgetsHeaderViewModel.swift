import Foundation
import Combine
import Services

@MainActor
final class WidgetsHeaderViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    private let onSpaceSelected: () -> Void
    
    private let accountSpaceId: String
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(accountSpaceId)
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceIcon: Icon?
    @Published var spaceUxType = ""
    @Published var spaceMembers = ""
    @Published var sharedSpace = false
    @Published var isOwner = false
    
    init(spaceId: String, onSpaceSelected: @escaping () -> Void) {
        self.accountSpaceId = spaceId
        self.onSpaceSelected = onSpaceSelected
    }
    
    func startSubscriptions() async {
        async let participantsTask: () = startParticipantsTask()
        async let spaceTask: () = startSpaceTask()
        async let participantSpaceViewTask: () = startParticipantSpaceViewTask()
        
        (_, _, _) = await (participantsTask, spaceTask, participantSpaceViewTask)
    }
    
    private func startParticipantsTask() async {
        for await participants in participantsSubscription.activeParticipantsPublisher.values {
            spaceMembers = Loc.Space.membersCount(participants.count)
        }
    }
    
    private func startSpaceTask() async {
        for await spaces in workspaceStorage.activeWorkspsacesPublisher.values {
            guard let space = spaces.first(where: { $0.targetSpaceId == accountSpaceId }) else { continue }
            spaceName = space.title
            spaceIcon = space.objectIconImage
            spaceUxType = space.uxType.name
            sharedSpace = space.isShared
        }
    }
    
    private func startParticipantSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: accountSpaceId).values {
            isOwner = participantSpaceView.isOwner
        }
    }
    
    func onTapSpaceSettings() {
        onSpaceSelected()
    }
}
