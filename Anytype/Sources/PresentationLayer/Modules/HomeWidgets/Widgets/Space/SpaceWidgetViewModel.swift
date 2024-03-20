import Foundation
import Combine
import Services

@MainActor
final class SpaceWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    private let onSpaceSelected: () -> Void
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceIcon: Icon?
    @Published var spaceAccessType = ""
    @Published var spaceMembers = ""
    @Published var spaceWithMembers = false
    
    init(onSpaceSelected: @escaping () -> Void) {
        self.onSpaceSelected = onSpaceSelected
    }
    
    func startParticipantTask() async {
        for await participants in activeSpaceParticipantStorage.participantsPublisher.values {
            spaceWithMembers = participants.count > 1
            spaceMembers = Loc.Space.membersCount(participants.count)
        }
    }
    
    func startSpaceTask() async {
        for await spaces in workspaceStorage.workspsacesPublisher.values {
            guard let space = spaces.first(where: { $0.targetSpaceId == activeWorkspaceStorage.workspaceInfo.accountSpaceId }) else { continue }
            spaceName = space.title
            spaceIcon = space.objectIconImage
            spaceAccessType = space.spaceAccessType?.name ?? ""
        }
    }
    
    func onTapWidget() {
        onSpaceSelected()
    }
}
