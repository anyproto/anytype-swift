import Foundation
import Services

struct SpaceMembersData: Identifiable, Hashable {
    let spaceId: String
    let route: SettingsSpaceMembersRoute
    var id: Int { hashValue }
}

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    @Published var participantInfo: ObjectInfo?
    
    // MARK: - DI

    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    
    private let data: SpaceMembersData
    
    // MARK: - State

    @Published var rows: [SpaceShareParticipantViewModel] = []
    private var isOwner = false
    private var participants: [Participant] = []
    
    init(data: SpaceMembersData) {
        self.data = data
    }
    
    func startParticipantTask() async {
        for await participants in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            self.participants = participants
            updateParticipant()
        }
    }

    func startSpacePermissionsTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: data.spaceId).values {
            isOwner = participantSpaceView.isOwner
            updateParticipant()
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceMembers(route: data.route)
    }
    
    private func updateParticipant() {
        let filteredParticipants = participants.filter { participant in
            if participant.status == .joining {
                return isOwner
            }
            return true
        }

        rows = filteredParticipants.map { participant in
            let isYou = accountManager.account.info.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.title) : participant.title,
                globalName: participant.displayGlobalName,
                status: .active(permission: participant.permission.title),
                action: SpaceShareParticipantViewModel.Action(title: nil, action: { [weak self] in
                    self?.showParticipantInfo(participant)
                }),
                contextActions: []
            )
        }
    }
    
    private func showParticipantInfo(_ participant: Participant) {
        participantInfo = ObjectInfo(objectId: participant.id, spaceId: participant.spaceId)
    }
}
