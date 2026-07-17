import SwiftUI
import Services
import ProtobufMessages


@MainActor
protocol NewInviteLinkModuleOutput: AnyObject {
    func showQrCode(url: URL)
    func shareInvite(url: URL)
    func showSpacesManager()
}

enum InviteShareToggleState {
    case off
    // Shared invites cannot be taken back into the owner's account — only reset
    case onLocked
    // Anyone-can-join editor invites cannot be shared within the space
    case blocked
}

@MainActor
@Observable
final class NewInviteLinkViewModel {

    var shareLink: URL? = nil
    var toastBarData: ToastBarData?
    var invitePickerItem: SpaceRichIviteType?
    var showInitialLoading = true
    var isLoading = false
    var inviteType: SpaceRichIviteType?
    var inviteChangeConfirmation: SpaceRichIviteType?
    var inviteHeldByOwner = false
    var isSharedWithinSpace = false
    var showShareConfirmation = false
    var showResetConfirmation = false

    var shareToggleState: InviteShareToggleState {
        if isSharedWithinSpace { return .onLocked }
        if inviteType == .editor { return .blocked }
        return .off
    }

    // Middleware refuses InviteChange above Reader on a shared invite (INVITE_NOT_SHAREABLE)
    var disabledPickerTypes: [SpaceRichIviteType] {
        isSharedWithinSpace && inviteType == .viewer ? [.editor] : []
    }

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
    private let data: SpaceShareData
    @ObservationIgnored
    private var spaceId: String { data.spaceId }
    @ObservationIgnored
    private var currentInvite: SpaceInvite?
    @ObservationIgnored
    private weak var output: (any NewInviteLinkModuleOutput)?

    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self.data = data
        self.output = output
    }

    func onAppear() async {
        await updateView()
        showInitialLoading = false
    }

    func updateLink() {
        Task { await updateView() }
    }

    func onInviteLinkTypeSelected(_ invite: SpaceRichIviteType) {
        invitePickerItem = nil
        guard inviteType != invite else { return }
        guard !inviteUpdateNeedsConfirmation(invite) else {
            inviteChangeConfirmation = invite
            return
        }

        updateInviteAndView(invite)
    }

    func onInviteChangeConfirmed(_ invite: SpaceRichIviteType) {
        updateInviteAndView(invite)
    }

    func onShareToggleChanged(_ isOn: Bool) {
        guard isOn, shareToggleState == .off else { return }
        showShareConfirmation = true
    }

    func onShareConfirmed() {
        guard let currentInvite, let inviteType = currentInvite.inviteType else { return }
        Task {
            isLoading = true
            do {
                defer { isLoading = false }
                // Publishes the very same invite into the space — same cid, same key, no new link
                _ = try await workspaceService.generateInvite(
                    spaceId: spaceId,
                    inviteType: inviteType,
                    permissions: currentInvite.permissions,
                    shareWithinSpace: true
                )
                await updateView()
            } catch {
                toastBarData = ToastBarData(error.localizedDescription)
            }
        }
    }

    func onResetLinkTap() {
        showResetConfirmation = true
    }

    func onResetConfirmed() {
        guard let currentInvite, let inviteType = currentInvite.inviteType else { return }
        Task {
            isLoading = true
            do {
                defer { isLoading = false }
                // Not atomic: if generate fails after revoke, the space is left without an invite.
                // updateView() in the catch recovers the UI to the disabled state so the owner can regenerate.
                try await workspaceService.revokeInvite(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(
                    spaceId: spaceId,
                    inviteType: inviteType,
                    permissions: currentInvite.permissions,
                    shareWithinSpace: false
                )
                await updateView()
            } catch {
                toastBarData = ToastBarData(error.localizedDescription)
                await updateView()
            }
        }
    }

    private func inviteUpdateNeedsConfirmation(_ invite: SpaceRichIviteType) -> Bool {
        guard inviteType != .disabled else { return false }

        switch invite {
        case .editor:
            return inviteType != .viewer
        case .viewer:
            return inviteType != .editor
        case .requestAccess:
            return true
        case .disabled:
            return true
        }
    }

    private func updateInviteAndView(_ invite: SpaceRichIviteType) {
        Task {
            isLoading = true
            do {
                defer { isLoading = false }

                try await updateInvite(invite)
                if invite.isShared { AnytypeAnalytics.instance().logShareSpace() }
                if let analyticsValue = invite.analyticsValue { AnytypeAnalytics.instance().logClickShareSpaceNewLink(type: analyticsValue) }
                await updateView()
            } catch {
                toastBarData = ToastBarData(error.localizedDescription)
            }
        }
    }

    private func updateInvite(_ type: SpaceRichIviteType) async throws {
        switch type {
        case .editor:
            if inviteType == .viewer {
                try await workspaceService.changeInvite(spaceId: spaceId, permissions: .writer)
            } else {
                try await workspaceService.makeSharable(spaceId: spaceId)
                try await workspaceService.revokeInvite(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
            }
        case .viewer:
            if inviteType == .editor {
                try await workspaceService.changeInvite(spaceId: spaceId, permissions: .reader)
            } else {
                try await workspaceService.makeSharable(spaceId: spaceId)
                try await workspaceService.revokeInvite(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .reader)
            }
        case .requestAccess:
            try await workspaceService.makeSharable(spaceId: spaceId)
            try await workspaceService.revokeInvite(spaceId: spaceId)
            _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .member, permissions: nil)
        case .disabled:
            try await workspaceService.revokeInvite(spaceId: spaceId)
        }
    }

    func onCopyLink(route: ClickShareSpaceCopyLinkRoute) {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink(route: route)
        UIPasteboard.general.string = shareLink?.absoluteString
        toastBarData = ToastBarData(Loc.copied)
    }

    func onShareInvite() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .shareLink)
        AnytypeAnalytics.instance().logClickShareSpaceShareLink(route: .membersScreen)
        guard let shareLink else { return }
        output?.shareInvite(url: shareLink)
    }

    func onShowQrCode() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .qr)
        guard let shareLink else { return }
        output?.showQrCode(url: shareLink)
    }

    func onLinkTypeTap() {
        invitePickerItem = inviteType
    }

    private func updateView() async {
        AnytypeAnalytics.instance().logScreenSettingsSpaceShare(route: data.route)

        do {
            let invite = try await workspaceService.getCurrentInvite(spaceId: spaceId)
            currentInvite = invite
            if invite.heldByOwner && !invite.hasLink {
                // Member's device — the invite is kept in the owner's account
                inviteHeldByOwner = true
                isSharedWithinSpace = false
                inviteType = nil
                shareLink = nil
            } else {
                inviteHeldByOwner = false
                isSharedWithinSpace = !invite.heldByOwner
                inviteType = invite.richInviteType
                shareLink = invite.hasLink ? universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey)) : nil
            }
        } catch let error as Anytype_Rpc.Space.InviteGetCurrent.Response.Error {
            resetState(inviteType: error.code == .noActiveInvite ? .disabled : nil)
        } catch {
            resetState(inviteType: nil)
        }
    }

    private func resetState(inviteType: SpaceRichIviteType?) {
        self.inviteType = inviteType
        currentInvite = nil
        shareLink = nil
        inviteHeldByOwner = false
        isSharedWithinSpace = false
    }
}
