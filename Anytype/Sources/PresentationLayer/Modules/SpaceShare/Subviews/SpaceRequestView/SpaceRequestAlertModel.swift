import Foundation
import Services


@MainActor
final class SpaceRequestAlertModel: ObservableObject {

    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.participantService)
    private var participantService: any ParticipantServiceProtocol
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    
    private let data: SpaceRequestAlertData
    private let onMembershipUpgradeTap: (MembershipUpgradeReason) -> ()
    private let onReject: (() -> Void)?
    
    let title: String
    let icon: ObjectIcon?
    @Published var canAddWriter = false
    
    var membershipLimitsExceeded: MembershipParticipantUpgradeReason? {
        if !canAddWriter {
            .numberOfSpaceEditors
        } else {
            nil
        }
    }
    
    init(data: SpaceRequestAlertData, onMembershipUpgradeTap: @escaping (MembershipUpgradeReason) -> (), onReject: (() -> Void)?) {
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
        onReject?()
    }
    
    func onMembershipUpgrade(reason: MembershipUpgradeReason) {
        onMembershipUpgradeTap(reason)
    }
}
