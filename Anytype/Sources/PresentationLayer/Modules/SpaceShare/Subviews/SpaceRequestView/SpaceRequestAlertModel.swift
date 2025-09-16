import Foundation
import Services


@MainActor
final class SpaceRequestAlertModel: ObservableObject {

    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.participantService)
    private var participantService: any ParticipantServiceProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    
    private let data: SpaceRequestAlertData
    private let onMembershipUpgradeTap: (MembershipUpgradeReason) -> ()
    private let onReject: (() async throws -> Void)?
    
    let title: String
    let icon: ObjectIcon?
    @Published var canAddReaded = false
    @Published var canAddWriter = false
    
    var membershipLimitsExceeded: MembershipParticipantUpgradeReason? {
        if !canAddReaded {
            .numberOfSpaceReaders
        } else if !canAddWriter {
            .numberOfSpaceEditors
        } else {
            nil
        }
    }
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping (MembershipUpgradeReason) -> (), onReject: (() async throws -> Void)?) {
        self.data = data
        self.onMembershipUpgradeTap = onMembershipUpgradeTap
        self.onReject = onReject
        title = Loc.SpaceShare.ViewRequest.title(
            data.participantName.withPlaceholder,
            data.spaceName.withPlaceholder
        )
        icon = data.participantIcon
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
        let spaceView = workspaceStorage.spaceView(spaceId: data.spaceId)
        AnytypeAnalytics.instance().logApproveInviteRequest(type: .read, spaceUxType: spaceView?.uxType)
        try await workspaceService.requestApprove(
            spaceId: data.spaceId,
            identity: data.participantIdentity,
            permissions: .reader
        )
    }
    
    func onEditAccess() async throws {
        let spaceView = workspaceStorage.spaceView(spaceId: data.spaceId)
        AnytypeAnalytics.instance().logApproveInviteRequest(type: .write, spaceUxType: spaceView?.uxType)
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
        try await onReject?()
    }
    
    func onMembershipUpgrade(reason: MembershipUpgradeReason) {
        onMembershipUpgradeTap(reason)
    }
}
