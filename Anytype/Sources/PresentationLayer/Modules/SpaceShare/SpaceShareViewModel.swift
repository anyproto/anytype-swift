import Foundation
import Services
import UIKit
import DeepLinks
import Combine

@MainActor
final class SpaceShareViewModel: ObservableObject {
    
    private enum Constants {
        static let participantLimit = 11 // 10 participants and 1 owner
    }
    
    @Injected(\.activeSpaceParticipantStorage)
    private var activeSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.deepLinkParser)
    private var deppLinkParser: DeepLinkParserProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: WorkspacesStorageProtocol
    
    private var onMoreInfo: () -> Void
    private var participants: [Participant] = []
    private lazy var workspaceInfo = activeWorkspaceStorage.workspaceInfo
    private var spaceView: SpaceView?
    
    var accountSpaceId: String { workspaceInfo.accountSpaceId }
    
    @Published var rows: [SpaceShareParticipantViewModel] = []
    @Published var inviteLink: URL?
    @Published var shareInviteLink: URL?
    @Published var qrCodeInviteLink: URL?
    @Published var allowToAddMembers = false
    @Published var toastBarData: ToastBarData = .empty
    @Published var requestAlertModel: SpaceRequestAlertData?
    @Published var changeAccessAlertModel: SpaceChangeAccessViewModel?
    @Published var removeParticipantAlertModel: SpaceParticipantRemoveViewModel?
    @Published var showDeleteLinkAlert = false
    @Published var showStopSharingAlert = false
    @Published var canStopShare = false
    
    nonisolated init(onMoreInfo: @escaping () -> Void) {
        self.onMoreInfo = onMoreInfo
    }
    
    func startParticipantsTask() async {
        for await items in activeSpaceParticipantStorage.participantsPublisher.values {
            updateParticipant(items: items)
        }
    }
    
    func startSpaceViewTask() async {
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: accountSpaceId).values {
            canStopShare = spaceView.canStopShare
        }
    }
    
    func onAppear() async {
        do {
            let invite = try await workspaceService.getCurrentInvite(spaceId: accountSpaceId)
            inviteLink = deppLinkParser.createUrl(deepLink: .invite(cid: invite.cid, key: invite.fileKey), scheme: .main)
        } catch {}
    }
    
    func onShareInvite() {
        shareInviteLink = inviteLink
    }
    
    func onCopyLink() {
        UIPasteboard.general.string = inviteLink?.absoluteString
        toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
    }
    
    func onDeleteSharingLink() {
        showDeleteLinkAlert = true
    }
    
    func onGenerateInvite() async throws {
        let invite = try await workspaceService.generateInvite(spaceId: accountSpaceId)
        inviteLink = deppLinkParser.createUrl(deepLink: .invite(cid: invite.cid, key: invite.fileKey), scheme: .main)
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
        qrCodeInviteLink = inviteLink
    }
    
    func onMoreInfoTap() {
        onMoreInfo()
    }
    
    // MARK: - Private
    
    private func updateParticipant(items: [Participant]) {
        participants = items.sorted { $0.sortingWeight > $1.sortingWeight }
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
        allowToAddMembers = Constants.participantLimit > items.count
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
                action: { [weak self] in
                    self?.showPermissionAlert(participant: participant, newPermission: .reader)
                }
            ),
            SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.Permissions.writer,
                isSelected: participant.permission == .writer,
                destructive: false,
                action: { [weak self] in
                    self?.showPermissionAlert(participant: participant, newPermission: .writer)
                }
            ),
            SpaceShareParticipantViewModel.ContextAction(
                title: Loc.SpaceShare.RemoveMember.title,
                isSelected: false,
                destructive: true,
                action: { [weak self] in
                    self?.showRemoveAlert(participant: participant)
                }
            )
        ]
    }
    
    private func showRequestAlert(participant: Participant) {
        guard let spaceView = activeWorkspaceStorage.spaceView() else { return }
        
        requestAlertModel = SpaceRequestAlertData(
            spaceId: spaceView.targetSpaceId,
            spaceName: spaceView.title,
            participantIdentity: participant.identity,
            participantName: participant.title
        )
    }
    
    private func showPermissionAlert(participant: Participant, newPermission: ParticipantPermissions) {
        guard participant.permission != newPermission else { return }
        changeAccessAlertModel = SpaceChangeAccessViewModel(
            participantName: participant.title,
            permissions: newPermission.title,
            onConfirm: { [weak self] in
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
                try await self?.workspaceService.participantRemove(spaceId: participant.spaceId, identity: participant.identity)
            }
        )
    }
}

private extension Participant {
    var sortingWeight: Int {
        if permission == .owner {
            return 4
        }
        
        if status == .joining {
            return 3
        }
        
        if status == .declined {
            return 1
        }
        
        return 2
    }
}
