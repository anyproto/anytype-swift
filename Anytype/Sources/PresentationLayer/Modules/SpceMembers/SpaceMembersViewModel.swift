import Foundation
import Services

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    
    private let spaceId: String
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func startParticipantTask() async {
        for await participants in participantsSubscription.activeParticipantsPublisher.values {
            updateParticipant(items: participants)
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceMembers()
    }
    
    private func updateParticipant(items: [Participant]) {
        rows = items.map { participant in
            let isYou = accountManager.account.info.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.title) : participant.title,
                status: .active(permission: participant.permission.title),
                action: nil,
                contextActions: []
            )
        }
    }
}
