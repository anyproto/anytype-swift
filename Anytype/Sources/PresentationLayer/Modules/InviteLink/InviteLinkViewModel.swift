import SwiftUI
import Services

@MainActor
protocol InviteLinkModuleOutput: AnyObject {
    func showQrCode(url: URL)
    func shareInvite(url: URL)
}

@MainActor
final class InviteLinkViewModel: ObservableObject {
    
    @Published var inviteLink: URL? = nil
    @Published var shareInviteLink: URL? = nil
    @Published var canDeleteLink = false
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
    
    init(data: SpaceShareData, output: (any InviteLinkModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    func startSubscription() async {
        async let spaceViewSubscription: () = startSpaceViewTask()
        async let getCurrentInvite: () = getCurrentInvite()
        (_, _) = await (spaceViewSubscription, getCurrentInvite)
    }
    
    private func getCurrentInvite() async {
        AnytypeAnalytics.instance().logScreenSettingsSpaceShare(route: data.route)
        do {
            let invite = try await workspaceService.getCurrentInvite(spaceId: spaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch {}
    }
    
    private func startSpaceViewTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            self.participantSpaceView = participantSpaceView
            updateView()
        }
    }
    
    func onGenerateInvite() async throws {
        guard let spaceView = participantSpaceView?.spaceView else { return }
        
        AnytypeAnalytics.instance().logShareSpace()
        
        if !spaceView.isShared {
            try await workspaceService.makeSharable(spaceId: spaceId)
        }
        
        let invite = try await workspaceService.generateInvite(spaceId: spaceId)
        inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
    }
    
    func onDeleteSharingLink() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .revoke)
        deleteLinkSpaceId = spaceId.identifiable
    }
    
    func onDeleteLinkCompleted() {
        inviteLink = nil
    }
    
    func onCopyLink() {
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink()
        UIPasteboard.general.string = inviteLink?.absoluteString
        toastBarData = ToastBarData(text: Loc.copied, showSnackBar: true)
    }
    
    func onShareInvite() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .shareLink)
        guard let inviteLink else { return }
        output?.shareInvite(url: inviteLink)
    }
    
    func onShowQrCode() {
        AnytypeAnalytics.instance().logClickSettingsSpaceShare(type: .qr)
        guard let inviteLink else { return }
        output?.showQrCode(url: inviteLink)
    }
    
    private func updateView() {
        guard let participantSpaceView else { return }
        canDeleteLink = participantSpaceView.permissions.canDeleteLink
        if !participantSpaceView.spaceView.isShared {
            inviteLink = nil
        }
    }
}
