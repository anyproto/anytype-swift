import Foundation
import Services
import UIKit
import DeepLinks
import Combine
import AnytypeCore

@MainActor
final class NewSpaceShareViewModel: ObservableObject {
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.membershipStatusStorage)
    private var membershipStatusStorage: any MembershipStatusStorageProtocol
    @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(spaceId)
    
    private var participants: [Participant] = []
    private var participantSpaceView: ParticipantSpaceViewData?
    private var canChangeWriterToReader = false
    private var canChangeReaderToWriter = false
    
    let data: SpaceShareData
    weak var output: (any NewInviteLinkModuleOutput)?
    var spaceId: String { data.spaceId }
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    @Published var toastBarData: ToastBarData?
    @Published var requestAlertModel: SpaceRequestAlertData?
    @Published var changeAccessAlertModel: SpaceChangeAccessViewModel?
    @Published var removeParticipantAlertModel: SpaceParticipantRemoveViewModel?
    @Published var showStopSharingAlert = false
    @Published var showUpgradeBadge = false
    @Published var canStopShare = false
    @Published var canDeleteLink = false
    @Published var canRemoveMember = false
    @Published var canApproveRequests = false
    @Published var upgradeTooltipData: MembershipParticipantUpgradeReason?
    @Published var membershipUpgradeReason: MembershipUpgradeReason?
    @Published var participantInfo: ObjectInfo?
    
    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func startParticipantsTask() async {
        for await items in participantsSubscription.withoutRemovingParticipantsPublisher.values {
            participants = items.sorted { $0.sortingWeight > $1.sortingWeight }
            updateView()
        }
    }
    
    func startSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            self.participantSpaceView = participantSpaceView
            updateView()
        }
    }
    
    func onStopSharing() {
        showStopSharingAlert = true
    }
    
    func onUpgradeTap(reason: MembershipParticipantUpgradeReason, route: ClickUpgradePlanTooltipRoute) {
        onUpgradeTap(reason: MembershipUpgradeReason(participantReason: reason), route: route)
    }
    
    func onUpgradeTap(reason: MembershipUpgradeReason, route: ClickUpgradePlanTooltipRoute) {
        AnytypeAnalytics.instance().logClickUpgradePlanTooltip(type: reason.analyticsType, route: route)
        membershipUpgradeReason = reason
    }
    
    // MARK: - Private
    
    private func updateView() {
        let workspaceInfo = workspacesStorage.workspaceInfo(spaceId: spaceId)
        guard let participantSpaceView, let workspaceInfo else { return }
        
        canStopShare = participantSpaceView.canStopSharing
        canChangeReaderToWriter = participantSpaceView.permissions.canEditPermissions
            && participantSpaceView.spaceView.canChangeReaderToWriter(participants: participants)
        canChangeWriterToReader = participantSpaceView.permissions.canEditPermissions 
            && participantSpaceView.spaceView.canChangeWriterToReader(participants: participants)
        canRemoveMember = participantSpaceView.permissions.canEditPermissions
        canDeleteLink = participantSpaceView.permissions.canDeleteLink
        canApproveRequests = participantSpaceView.permissions.canApproveRequests
        
        updateUpgradeViewState()
        
        rows = participants.map { participant in
            let isYou = workspaceInfo.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.title) : participant.title,
                globalName: participant.displayGlobalName,
                status: participantStatus(participant),
                action: participantAction(participant),
                contextActions: participantContextActions(participant)
            )
        }
    }
    
    private func updateUpgradeViewState() {
        guard let participantSpaceView else { return }
        
        let canAddReaders = participantSpaceView.spaceView.canAddReaders(participants: participants)
        let canAddWriters = participantSpaceView.spaceView.canAddWriters(participants: participants)
        let haveJoiningParticipants = participants.contains { $0.status == .joining }
        
        
        if !canAddReaders && haveJoiningParticipants {
            upgradeTooltipData = .numberOfSpaceReaders
        } else if !canAddWriters {
            upgradeTooltipData = .numberOfSpaceEditors
        } else {
            upgradeTooltipData = nil
        }
    }
    
    private func participantStatus(_ participant: Participant) -> SpaceShareParticipantViewModel.Status? {
        switch participant.status {
        case .active:
            return .active(permission: participant.permission.title)
        case .joining:
            return .pending(message: Loc.setAccess)
        case .removing:
            return .pending(message: Loc.SpaceShare.leaveRequest)
        case .declined, .canceled, .removed, .UNRECOGNIZED:
            return nil
        }
    }
    
    private func participantAction(_ participant: Participant) -> SpaceShareParticipantViewModel.Action? {
        return SpaceShareParticipantViewModel.Action(title: nil, action: { [weak self] in
            self?.showParticipantInfo(participant)
        })
    }
    
    private func participantContextActions(_ participant: Participant) -> [SpaceShareParticipantViewModel.ContextAction] {
        guard participant.permission != .owner else { return [] }
        switch participant.status {
        case .active:
            return [
                SpaceShareParticipantViewModel.ContextAction(
                    title: Loc.SpaceShare.Permissions.reader,
                    isSelected: participant.permission == .reader,
                    destructive: false,
                    enabled: canChangeWriterToReader || participant.permission == .reader,
                    action: { [weak self] in
                        self?.showPermissionAlert(participant: participant, newPermission: .reader)
                    }
                ),
                SpaceShareParticipantViewModel.ContextAction(
                    title: Loc.SpaceShare.Permissions.writer,
                    isSelected: participant.permission == .writer,
                    destructive: false,
                    enabled: canChangeReaderToWriter || participant.permission == .writer,
                    action: { [weak self] in
                        self?.showPermissionAlert(participant: participant, newPermission: .writer)
                    }
                ),
                SpaceShareParticipantViewModel.ContextAction(
                    title: Loc.SpaceShare.RemoveMember.title,
                    isSelected: false,
                    destructive: true,
                    enabled: canRemoveMember,
                    action: { [weak self] in
                        self?.showRemoveAlert(participant: participant)
                    }
                )]
        case .joining:
            return [SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.Action.viewRequest,
                isSelected: false,
                destructive: false,
                enabled: canApproveRequests,
                action: { [weak self] in
                    self?.showRequestAlert(participant: participant)
                }
            )]
        case .removing:
            return [
                SpaceShareParticipantViewModel.ContextAction(
                    title: Loc.SpaceShare.Action.approve,
                    isSelected: false,
                    destructive: false,
                    enabled: canApproveRequests,
                    action: { [weak self] in
                        AnytypeAnalytics.instance().logApproveLeaveRequest()
                        try await self?.workspaceService.leaveApprove(spaceId: participant.spaceId, identity: participant.identity)
                        self?.toastBarData = ToastBarData(Loc.SpaceShare.Approve.toast(participant.title))
                    }
                )]
        case .removed, .declined, .canceled, .UNRECOGNIZED(_):
            return []
        }
    }
    
    private func showRequestAlert(participant: Participant) {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        
        requestAlertModel = SpaceRequestAlertData(
            spaceId: spaceView.targetSpaceId,
            spaceName: spaceView.title,
            participantIdentity: participant.identity,
            participantName: participant.title,
            participantIcon: participant.icon,
            route: .settings
        )
    }
    
    private func showPermissionAlert(participant: Participant, newPermission: ParticipantPermissions) {
        guard participant.permission != newPermission else { return }
        changeAccessAlertModel = SpaceChangeAccessViewModel(
            participantName: participant.title,
            permissions: newPermission.title,
            onConfirm: { [weak self] in
                AnytypeAnalytics.instance().logChangeSpaceMemberPermissions(type: newPermission.analyticsType)
                try await self?.workspaceService.participantPermissionsChange(
                    spaceId: participant.spaceId,
                    identity: participant.identity,
                    permissions: newPermission
                )
                self?.toastBarData = ToastBarData(Loc.SpaceShare.accessChanged, type: .success)
            }
        )
    }
    
    private func showRemoveAlert(participant: Participant) {
        removeParticipantAlertModel = SpaceParticipantRemoveViewModel(
            participantName: participant.title,
            onConfirm: { [weak self] in
                AnytypeAnalytics.instance().logRemoveSpaceMember()
                try await self?.workspaceService.participantRemove(spaceId: participant.spaceId, identity: participant.identity)
            }
        )
    }
    
    private func showParticipantInfo(_ participant: Participant) {
        participantInfo = ObjectInfo(objectId: participant.id, spaceId: participant.spaceId)
    }
}

private extension Participant {
    var sortingWeight: Int {
        if permission == .owner {
            return 1000
        }
        
        if status == .joining {
            return 30
        }
        
        if status == .removing {
            return 20
        }
        
        if permission == .writer {
            return 5
        }
        
        if permission == .reader {
            return 4
        }
        
        return 1
    }
}
