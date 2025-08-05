import SwiftUI
import Services

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
    @Published var showLoading = true
    
    @Published private var participantSpaceView: ParticipantSpaceViewData?
    
    @Published var inviteType: SpaceRichIviteType? = .disabled
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
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
    
    func startSubscription() async {
        async let spaceViewSubscription: () = startSpaceViewSubscription()
        (_) = await (spaceViewSubscription)
    }
    
    private func startSpaceViewSubscription() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            self.participantSpaceView = participantSpaceView
            await updateView()
        }
    }
    
    // TBD: Update without revoiking. Waiting for middleware
    func onInviteLinkTypeSelected(_ type: SpaceRichIviteType) {
        invitePickerItem = nil
        guard self.inviteType != type else { return }
        
        Task {
            do {
                switch type {
                case .editor:
                    try await workspaceService.revokeInvite(spaceId: spaceId)
                    _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .writer)
                case .viewer:
                    try await workspaceService.revokeInvite(spaceId: spaceId)
                    _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .withoutApprove, permissions: .reader)
                case .requestAccess:
                    try await workspaceService.revokeInvite(spaceId: spaceId)
                    _ = try await workspaceService.generateInvite(spaceId: spaceId, inviteType: .member, permissions: nil)
                case .disabled:
                    try await workspaceService.revokeInvite(spaceId: spaceId)
                }
            } catch {
                toastBarData = ToastBarData(error.localizedDescription)
            }
            
            await updateView()
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
        guard let participantSpaceView else { return }
        await updateInvite()
        if !participantSpaceView.spaceView.isShared {
            shareLink = nil
        }
    }
    
    private func updateInvite() async {
        defer { showLoading = false }
        AnytypeAnalytics.instance().logScreenSettingsSpaceShare(route: data.route)
        
        do {
            let invite = try await workspaceService.getCurrentInvite(spaceId: spaceId)
            inviteType = invite.richInviteType
            
            shareLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } catch {}
    }
}
