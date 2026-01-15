import Foundation
import Services

@MainActor
@Observable
final class SpaceInfoViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    @ObservationIgnored
    private let spaceId: String
    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)

    // MARK: - State

    var spaceName = ""
    var spaceIcon: Icon?
    var spaceUxType = ""
    var spaceMembers = ""
    var sharedSpace = false

    init(spaceId: String) {
        self.spaceId = spaceId
    }

    func startSubscriptions() async {
        async let participantsTask: () = startParticipantsTask()
        async let spaceTask: () = startSpaceTask()

        (_, _) = await (participantsTask, spaceTask)
    }

    private func startParticipantsTask() async {
        for await participants in participantsSubscription.activeParticipantsPublisher.values {
            spaceMembers = Loc.Space.membersCount(participants.count)
        }
    }

    private func startSpaceTask() async {
        for await spaces in workspaceStorage.activeSpaceViewsPublisher.values {
            guard let space = spaces.first(where: { $0.targetSpaceId == spaceId }) else { continue }
            spaceName = space.title
            spaceIcon = space.objectIconImage
            spaceUxType = space.uxType.name
            sharedSpace = space.isShared
        }
    }
}
