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
    var isOneToOne = false
    var hasMembership = false
    var anytypeName = ""

    @ObservationIgnored
    private var oneToOneIdentity = ""
    @ObservationIgnored
    private var participants: [Participant] = []

    init(spaceId: String) {
        self.spaceId = spaceId
    }

    func startSubscriptions() async {
        async let participantsTask: () = startParticipantsTask()
        async let spaceTask: () = startSpaceTask()
        async let oneToOneTask: () = startOneToOneParticipantTask()

        (_, _, _) = await (participantsTask, spaceTask, oneToOneTask)
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
            isOneToOne = space.uxType.isOneToOne
            oneToOneIdentity = space.oneToOneIdentity
            updateOneToOneParticipant()
        }
    }

    private func startOneToOneParticipantTask() async {
        for await participants in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            self.participants = participants
            updateOneToOneParticipant()
        }
    }

    private func updateOneToOneParticipant() {
        guard oneToOneIdentity.isNotEmpty else { return }
        guard let participant = participants.first(where: { $0.identity == oneToOneIdentity }) else { return }

        hasMembership = participant.globalName.isNotEmpty
        anytypeName = participant.displayGlobalNameTruncated
    }
}
