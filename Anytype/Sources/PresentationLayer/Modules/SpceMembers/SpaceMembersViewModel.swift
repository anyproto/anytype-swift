import Foundation
import Services

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.participantSubscriptionBySpaceService)
    private var participantSubscriptionService: ParticipantsSubscriptionBySpaceServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    func onAppear() async {
        await participantSubscriptionService.startSubscription(mode: .member) { [weak self] items in
            self?.updateParticipant(items: items)
        }
    }
    
    private func updateParticipant(items: [Participant]) {
        rows = items.map { participant in
            let isYou = accountManager.account.info.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.name) :  participant.name,
                status: .active(permission: participant.permission.title),
                action: nil,
                contextActions: []
            )
        }
    }
}
