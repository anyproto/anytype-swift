import Foundation
import Services
import UIKit
import DeepLinks
import Combine
import AnytypeCore

@MainActor
final class SpaceShareViewModel: ObservableObject {
    
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: UniversalLinkParserProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: ParticipantSpacesStorageProtocol
    
    private var onMoreInfo: () -> Void
    private var participants: [Participant] = []
    private var participantSpaceView: ParticipantSpaceView?
    private var canChangeWriterToReader = false
    private var canChangeReaderToWriter = false
    private lazy var workspaceInfo = activeWorkspaceStorage.workspaceInfo
    
    var accountSpaceId: String { workspaceInfo.accountSpaceId }
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    @Published var inviteLink: URL?
    @Published var shareInviteLink: URL?
    @Published var qrCodeInviteLink: URL?
    @Published var toastBarData: ToastBarData = .empty
    @Published var requestAlertModel: SpaceRequestAlertData?
    @Published var changeAccessAlertModel: SpaceChangeAccessViewModel?
    @Published var removeParticipantAlertModel: SpaceParticipantRemoveViewModel?
    @Published var showDeleteLinkAlert = false
    @Published var showStopSharingAlert = false
    @Published var canStopShare = false
    
    init(onMoreInfo: @escaping () -> Void) {
        self.onMoreInfo = onMoreInfo
    }
    
    func startParticipantsTask() async {
        for await items in activeSpaceParticipantStorage.participantsPublisher.values {
            participants = items.sorted { $0.sortingWeight > $1.sortingWeight }
            updateView()
        }
    }
    
    func startSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: accountSpaceId).values {
            self.participantSpaceView = participantSpaceView
            updateView()
        }
    }
    
    func onAppear() async {
        AnytypeAnalytics.instance().logScreenSettingsSpaceShare()
        do {
            let invite = try await workspaceService.getCurrentInvite(spaceId: accountSpaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch {}
    }
    
    func onShareInvite() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .shareLink)
        shareInviteLink = inviteLink
    }
    
    func onCopyLink() {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
        UIPasteboard.general.string = inviteLink?.absoluteString
        toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
    }
    
    func onDeleteSharingLink() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .revoke)
        showDeleteLinkAlert = true
    }
    
    func onGenerateInvite() async throws {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        
        AnytypeAnalytics.instance().logShareSpace()
        
        if !spaceView.isShared {
            try await workspaceService.makeSharable(spaceId: accountSpaceId)
        }
        
        let invite = try await workspaceService.generateInvite(spaceId: accountSpaceId)
        inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
    }
    
    func onDeleteLinkCompleted() {
        inviteLink = nil
    }
    
    func onStopSharing() {
        showStopSharingAlert = true
    }
    
    func onStopSharingCompleted() {
        inviteLink = nil
    }
    
    func onShowQrCode() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .qr)
        qrCodeInviteLink = inviteLink
    }
    
    func onMoreInfoTap() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .moreInfo)
        onMoreInfo()
    }
    
    // MARK: - Private
    
    private func updateView() {
        guard let participantSpaceView else { return }
        
        canStopShare = participantSpaceView.canStopShare
        canChangeReaderToWriter = participantSpaceView.spaceView.canChangeReaderToWriter(participants: participants)
        canChangeWriterToReader = participantSpaceView.spaceView.canChangeWriterToReader(participants: participants)
        
        rows = participants.map { participant in
            let isYou = workspaceInfo.profileObjectID == participant.identityProfileLink
            return SpaceShareParticipantViewModel(
                id: participant.id,
                icon: participant.icon?.icon,
                name: isYou ? Loc.SpaceShare.youSuffix(participant.title) : participant.title,
                status: participantStatus(participant),
                action: participantAction(participant),
                contextActions: participantContextActions(participant)
            )
        }
    }
    
    private func participantStatus(_ participant: Participant) -> SpaceShareParticipantViewModel.Status? {
        switch participant.status {
        case .active:
            return .active(permission: participant.permission.title)
        case .joining:
            return .pending(message: Loc.SpaceShare.joinRequest)
        case .removing:
            return .pending(message: Loc.SpaceShare.leaveRequest)
        case .declined, .canceled, .removed, .UNRECOGNIZED:
            return nil
        }
    }
    
    private func participantAction(_ participant: Participant) -> SpaceShareParticipantViewModel.Action? {
        switch participant.status {
        case .joining:
            return SpaceShareParticipantViewModel.Action(title: Loc.SpaceShare.Action.viewRequest, action: { [weak self] in
                self?.showRequestAlert(participant: participant)
            })
        case .removing:
            return SpaceShareParticipantViewModel.Action(title: Loc.SpaceShare.Action.approve, action: { [weak self] in
                AnytypeAnalytics.instance().logApproveLeaveRequest()
                try await self?.workspaceService.leaveApprove(spaceId: participant.spaceId, identity: participant.identity)
                self?.toastBarData = ToastBarData(text: Loc.SpaceShare.Approve.toast(participant.title), showSnackBar: true)
            })
        case .active, .canceled, .declined, .removed, .UNRECOGNIZED:
            return nil
        }
    }
    
    private func participantContextActions(_ participant: Participant) -> [SpaceShareParticipantViewModel.ContextAction] {
        guard participant.permission != .owner, participant.status == .active else { return [] }
        return [
            SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.Permissions.reader,
                isSelected: participant.permission == .reader,
                destructive: false,
                disabled: !canChangeWriterToReader && participant.permission != .reader,
                action: { [weak self] in
                    self?.showPermissionAlert(participant: participant, newPermission: .reader)
                }
            ),
            SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.Permissions.writer,
                isSelected: participant.permission == .writer,
                destructive: false,
                disabled: !canChangeReaderToWriter && participant.permission != .writer,
                action: { [weak self] in
                    self?.showPermissionAlert(participant: participant, newPermission: .writer)
                }
            ),
            SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.RemoveMember.title,
                isSelected: false,
                destructive: true,
                disabled: false,
                action: { [weak self] in
                    self?.showRemoveAlert(participant: participant)
                }
            )
        ]
    }
    
    private func showRequestAlert(participant: Participant) {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        
        requestAlertModel = SpaceRequestAlertData(
            spaceId: spaceView.targetSpaceId,
            spaceName: spaceView.title,
            participantIdentity: participant.identity,
            participantName: participant.title,
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
                self?.toastBarData = ToastBarData(text: Loc.SpaceShare.accessChanged, showSnackBar: true, messageType: .success)
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
}

private extension Participant {
    var sortingWeight: Int {
        if status == .joining {
            return 3
        }
        
        if status == .declined {
            return 2
        }
        
        return 1
    }
}
