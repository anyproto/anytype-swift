import Foundation
import Services

@MainActor
final class SpaceMembersViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: any ActiveSpaceParticipantStorageProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: any ActiveWorkpaceStorageProtocol
    
    // MARK: - State
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    
    func startParticipantTask() async {
        for await participants in activeSpaceParticipantStorage.activeParticipantsStream(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) {
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
