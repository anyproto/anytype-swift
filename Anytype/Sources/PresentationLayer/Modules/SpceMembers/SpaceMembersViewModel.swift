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
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(data.spaceId)
    
    private let data: SpaceMembersData
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    init(data: SpaceMembersData) {
        self.data = data
    }
    
    func startParticipantTask() async {
        for await participants in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            updateParticipant(items: participants)
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceMembers(route: data.route)
    }
    
    private func updateParticipant(items: [Participant]) {
        rows = items.map { participant in
            let isYou = accountManager.account.info.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.title) : participant.title,
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
