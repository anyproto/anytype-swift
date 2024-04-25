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
    
    // Store for prevent switch details when user switch space - IOS-2518
    private lazy var accountSpaceId: String = {
        activeWorkspaceStorage.workspaceInfo.accountSpaceId
    }()
    
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceIcon: Icon?
    @Published var spaceAccessType = ""
    @Published var spaceMembers = ""
    @Published var sharedSpace = false
    
    init(onSpaceSelected: @escaping () -> Void) {
        self.onSpaceSelected = onSpaceSelected
    }
    
    func startParticipantTask() async {
        for await participants in activeSpaceParticipantStorage.activeParticipantsPublisher.values {
            spaceMembers = Loc.Space.membersCount(participants.count)
        }
    }
    
    func startSpaceTask() async {
        for await spaces in workspaceStorage.activeWorkspsacesPublisher.values {
            guard let space = spaces.first(where: { $0.targetSpaceId == accountSpaceId }) else { continue }
            spaceName = space.title
            spaceIcon = space.objectIconImage
            spaceAccessType = space.spaceAccessType?.name ?? ""
            sharedSpace = space.isShared
        }
    }
    
    func onTapWidget() {
        onSpaceSelected()
    }
}
