import SwiftUI
import Services
import ProtobufMessages


@MainActor
protocol NewInviteLinkModuleOutput: AnyObject {
    func showQrCode(url: URL)
    func shareInvite(url: URL)
}

@MainActor
final class NewInviteLinkViewModel: ObservableObject {
    
    @Published var shareLink: URL? = nil
    @Published var inviteLink: URL? = nil
    @Published var toastBarData: ToastBarData?
    @Published var invitePickerItem: SpaceRichIviteType?
    @Published var showInitialLoading = true
    @Published var isLoading = false
    @Published var inviteType: SpaceRichIviteType?
    @Published var inviteChangeConfirmation: SpaceRichIviteType?
    
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    
    private let data: SpaceShareData
    var spaceId: String { data.spaceId }
    private weak var output: (any NewInviteLinkModuleOutput)?
    
    init(data: SpaceShareData, output: (any NewInviteLinkModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func onAppear() async {
        await updateView()
        showInitialLoading = false
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
                try await workspaceService.revokeInvite(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
            }
        case .viewer:
            if inviteType == .editor {
                try await workspaceService.changeInvite(spaceId: spaceId, permissions: .reader)
            } else {
                try await workspaceService.revokeInvite(spaceId: spaceId)
                _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .reader)
            }
        case .requestAccess:
            try await workspaceService.revokeInvite(spaceId: spaceId)
            _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .member, permissions: nil)
        case .disabled:
            try await workspaceService.revokeInvite(spaceId: spaceId)
        }
    }
    
    func onCopyInviteLink() {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
        UIPasteboard.general.string = inviteLink?.absoluteString
        toastBarData = ToastBarData(Loc.copied)
    }
    
    func onCopyLink() {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
        UIPasteboard.general.string = shareLink?.absoluteString
        toastBarData = ToastBarData(Loc.copied)
    }
    
    func onShareInvite() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .shareLink)
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
            inviteType = invite.richInviteType
            shareLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch let error as Anytype_Rpc.Space.InviteGetCurrent.Response.Error {
            if error.code == .noActiveInvite {
                inviteType = .disabled
                shareLink = nil
            } else {
                inviteType = nil
                shareLink = nil
            }
        } catch {
            inviteType = nil
            shareLink = nil
        }
    }
}
