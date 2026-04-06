import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
@Observable
final class WidgetsHeaderViewModel {

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    @ObservationIgnored
    private let onSpaceSelected: () -> Void
    @ObservationIgnored
    private let onMembersSelected: (String, SettingsSpaceShareRoute) -> Void
    @ObservationIgnored
    private let onQrCodeSelected: (URL) -> Void

    @ObservationIgnored
    private let accountSpaceId: String

    // MARK: - State

    var canEdit = false
    var toastBarData: ToastBarData?
    private(set) var spaceView: SpaceView?
    private(set) var inviteLink: URL?

    // MARK: - Computed Properties

    var isSharedSpace: Bool {
        spaceView?.spaceAccessType == .shared
    }

    var isPrivateSpace: Bool {
        spaceView?.spaceAccessType == .private
    }

    var isOneToOneSpace: Bool {
        spaceView?.isOneToOne == true
    }

    var supportsNotificationModeMenu: Bool {
        !(spaceView?.isOneToOne ?? true)
    }

    var hasInviteLink: Bool {
        inviteLink != nil
    }

    var currentNotificationMode: SpacePushNotificationsMode {
        spaceView?.pushNotificationMode ?? .all
    }

    var isMuted: Bool {
        !currentNotificationMode.isUnmutedAll
    }

    init(
        spaceId: String,
        onSpaceSelected: @escaping () -> Void,
        onMembersSelected: @escaping (String, SettingsSpaceShareRoute) -> Void,
        onQrCodeSelected: @escaping (URL) -> Void
    ) {
        self.accountSpaceId = spaceId
        self.onSpaceSelected = onSpaceSelected
        self.onMembersSelected = onMembersSelected
        self.onQrCodeSelected = onQrCodeSelected
    }

    func startSubscriptions() async {
        async let participantTask: () = startParticipantSpaceViewTask()
        async let spaceViewTask: () = startSpaceViewSubscription()
        (_, _) = await (participantTask, spaceViewTask)
    }

    private func startParticipantSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: accountSpaceId).values {
            canEdit = participantSpaceView.canEdit
        }
    }

    private func startSpaceViewSubscription() async {
        for await spaceViews in workspaceStorage.allSpaceViewsPublisher.values {
            if let spaceView = spaceViews.first(where: { $0.targetSpaceId == accountSpaceId }) {
                self.spaceView = spaceView
                await updateInviteLinkIfNeeded()
            }
        }
    }

    private func updateInviteLinkIfNeeded() async {
        guard isSharedSpace else {
            inviteLink = nil
            return
        }
        guard let spaceView, !spaceView.isOneToOne else {
            inviteLink = nil
            return
        }

        do {
            let invite: SpaceInvite
            if spaceView.uxType.isStream {
                invite = try await workspaceService.getGuestInvite(spaceId: accountSpaceId)
            } else {
                invite = try await workspaceService.getCurrentInvite(spaceId: accountSpaceId)
            }
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch {
            inviteLink = nil
        }
    }

    // MARK: - Actions

    func onChannelSettingsTap() {
        onSpaceSelected()
    }

    func onMembersTap() {
        onMembersSelected(accountSpaceId, .navigation)
    }

    func onInviteMembersTap() {
        onMembersSelected(accountSpaceId, .navigation)
    }

    func toggleMute() async {
        await onNotificationModeChanged(currentNotificationMode.toggled(isOneToOne: isOneToOneSpace))
    }

    func onNotificationModeChanged(_ mode: SpacePushNotificationsMode) async {
        do {
            try await workspaceService.pushNotificationSetSpaceMode(spaceId: accountSpaceId, mode: mode)
            AnytypeAnalytics.instance().logChangeMessageNotificationState(type: mode.analyticsValue, route: .vault, uxType: .space)
        } catch {
            anytypeAssertionFailure("Failed to set notification mode: \(error)")
        }
    }

    func onShowQrCodeTap() {
        guard let inviteLink else { return }
        onQrCodeSelected(inviteLink)
    }

    func onCopyInviteLinkTap() {
        guard let inviteLink else { return }
        UIPasteboard.general.string = inviteLink.absoluteString
        toastBarData = ToastBarData(Loc.copiedToClipboard(Loc.link), type: .success)
    }
}
