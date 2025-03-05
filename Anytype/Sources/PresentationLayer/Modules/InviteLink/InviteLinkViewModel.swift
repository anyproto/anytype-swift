import SwiftUI
import Services

@MainActor
protocol InviteLinkModuleOutput: AnyObject {
    func showQrCode(url: URL)
    func shareInvite(url: URL)
}

@MainActor
final class InviteLinkViewModel: ObservableObject {
    
    @Published var shareLink: URL? = nil
    @Published var inviteLink: URL? = nil
    @Published var canDeleteLink = false
    @Published var canCopyInviteLink = false
    @Published var deleteLinkSpaceId: StringIdentifiable? = nil
    @Published var toastBarData: ToastBarData = .empty
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    
    private let data: SpaceShareData
    var spaceId: String { workspaceInfo.accountSpaceId }
    private var workspaceInfo: AccountInfo { data.workspaceInfo }
    private var participantSpaceView: ParticipantSpaceViewData?
    private weak var output: (any InviteLinkModuleOutput)?
    
    var isStream: Bool { participantSpaceView?.spaceView.uxType.isStream ?? false }    
    var firstOpen = true
    
    init(data: SpaceShareData, output: (any InviteLinkModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func startSubscription() async {
        async let spaceViewSubscription: () = startSpaceViewTask()
        (_) = await (spaceViewSubscription)
    }
    
    private func getInvite() async {
        defer { firstOpen = false }
        AnytypeAnalytics.instance().logScreenSettingsSpaceShare(route: data.route)
        do {
            let invite = isStream ? try await workspaceService.getGuestInvite(spaceId: spaceId) : try await workspaceService.getCurrentInvite(spaceId: spaceId)
            
            shareLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch {}
    }
    
    private func startSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            self.participantSpaceView = participantSpaceView
            await updateView()
        }
    }
    
    func onGenerateInvite() async throws {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        
        AnytypeAnalytics.instance().logShareSpace()
        
        if !spaceView.isShared {
            try await workspaceService.makeSharable(spaceId: spaceId)
        }
        
        let invite = try await workspaceService.generateInvite(spaceId: spaceId)
        shareLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
    }
    
    func onDeleteSharingLink() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .revoke)
        deleteLinkSpaceId = spaceId.identifiable
    }
    
    func onDeleteLinkCompleted() {
        shareLink = nil
    }
    
    func onCopyInviteLink() {
        Task {
            if inviteLink.isNil {
                let invite = try await workspaceService.generateInvite(spaceId: spaceId)
                inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
            } else {
                let invite = try await workspaceService.getCurrentInvite(spaceId: spaceId)
                inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
            }
            AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
            UIPasteboard.general.string = inviteLink?.absoluteString
            toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
        }
    }
    
    func onCopyLink() {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
        UIPasteboard.general.string = shareLink?.absoluteString
        toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
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
    
    private func updateView() async {
        guard let participantSpaceView else { return }
        await getInvite()
        canDeleteLink = participantSpaceView.permissions.canDeleteLink
        canCopyInviteLink = participantSpaceView.spaceView.uxType.isStream
        if !participantSpaceView.spaceView.isShared {
            shareLink = nil
        }
    }
}
