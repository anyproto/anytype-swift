import Foundation
import Services

@MainActor
final class SpaceRequestAlertModel: ObservableObject {

    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.participantService)
    private var participantService: ParticipantServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private let data: SpaceRequestAlertData
    private let onMembershipUpgradeTap: () -> ()
    
    @Published var title = ""
    @Published var canAddReaded = false
    @Published var canAddWriter = false
    var showUpgradeButton: Bool {
        !canAddWriter && !canAddReaded
    }
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping () -> ()) {
        self.data = data
        self.onMembershipUpgradeTap = onMembershipUpgradeTap
        title = Loc.SpaceShare.ViewRequest.title(
            data.participantName.withPlaceholder,
            data.spaceName.withPlaceholder
        )
    }
    
    func onAppear() async throws {
        AnytypeAnalytics.instance().logScreenInviteConfirm(route: data.route)
        
        guard let spaceView = workspaceStorage.spaceView(spaceId: data.spaceId) else {
            throw CommonError.undefined
        }
        // Don't use participant from active subscription, because active space and space for request can be different
        let participants = try await participantService.searchParticipants(spaceId: data.spaceId)
        
        canAddReaded = spaceView.canAddReaders(participants: participants)
        canAddWriter = spaceView.canAddWriters(participants: participants)
    }
    
    func onViewAccess() async throws {
        AnytypeAnalytics.instance().logApproveInviteRequest(type: .read)
        try await workspaceService.requestApprove(
            spaceId: data.spaceId,
            identity: data.participantIdentity,
            permissions: .reader
        )
    }
    
    func onEditAccess() async throws {
        AnytypeAnalytics.instance().logApproveInviteRequest(type: .write)
        try await workspaceService.requestApprove(
            spaceId: data.spaceId,
            identity: data.participantIdentity,
            permissions: .writer
        )
    }

    func onReject() async throws {
        AnytypeAnalytics.instance().logRejectInviteRequest()
        try await workspaceService.requestDecline(
            spaceId: data.spaceId,
            identity: data.participantIdentity
        )
    }
    
    func onMembershipUpgrade() {
        onMembershipUpgradeTap()
    }
}
