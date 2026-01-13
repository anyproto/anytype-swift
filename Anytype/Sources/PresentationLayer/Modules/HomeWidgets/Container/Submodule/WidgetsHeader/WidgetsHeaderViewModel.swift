import Foundation
import Services

@MainActor
@Observable
final class WidgetsHeaderViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private let onSpaceSelected: () -> Void

    @ObservationIgnored
    private let accountSpaceId: String
    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(accountSpaceId)

    // MARK: - State

    var spaceName = ""
    var spaceIcon: Icon?
    var spaceUxType = ""
    var spaceMembers = ""
    var sharedSpace = false
    var isOneToOne = false
    var canEdit = false
    
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
        for await spaces in workspaceStorage.activeSpaceViewsPublisher.values {
            guard let space = spaces.first(where: { $0.targetSpaceId == accountSpaceId }) else { continue }
            spaceName = space.title
            spaceIcon = space.objectIconImage
            spaceUxType = space.uxType.name
            sharedSpace = space.isShared
            isOneToOne = space.uxType.isOneToOne
        }
    }
    
    private func startParticipantSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: accountSpaceId).values {
            canEdit = participantSpaceView.canEdit
        }
    }
    
    func onTapSpaceSettings() {
        onSpaceSelected()
    }
}
