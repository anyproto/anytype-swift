import Foundation
import Services

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    func startParticipantTask() async {
        for await participants in activeSpaceParticipantStorage.activeParticipantsPublisher.values {
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
