import SwiftUI
import Services
import AnytypeCore


@MainActor
final class SpaceProfileViewModel: ObservableObject {
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    @Published var spaceIcon: Icon?
    
    @Published var allowDelete = false
    @Published var allowLeave = false
    
    @Published var showInfoView = false
    @Published var showSpaceDeleteAlert = false
    @Published var showSpaceLeaveAlert = false
    
    @Published var settingsInfo = [SettingsInfoModel]()
    @Published var snackBarData: ToastBarData?
    
    @Published var shareInviteLink: URL?
    @Published var qrInviteLink: URL?
    @Published var inviteLink: URL?
    
    let workspaceInfo: AccountInfo
    
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.spaceSettingsInfoBuilder)
    private var spaceSettingsInfoBuilder: any SpaceSettingsInfoBuilderProtocol
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)
    
    private var owner: Participant?
    private var participantSpaceView: ParticipantSpaceViewData?
    private var linkUpdated: Bool = false
    
    init(info: AccountInfo) {
        self.spaceInfo = info
    }
    
    func setupSubscriptions() async {
        async let participantTask: () = startParticipantTask()
        async let ownerTask: () = startOwnerTask()
        
        (_) = await (participantTask, ownerTask)
    }
    
    func onInfoTap() {
        showInfoView.toggle()
    }
    
    func onDeleteTap() {
        AnytypeAnalytics.instance().logClickDeleteSpace(route: .settings)
        showSpaceDeleteAlert.toggle()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    func onQRCodeTap() {
        qrInviteLink = inviteLink
    }
    
    func onShareTap() {
        AnytypeAnalytics.instance().logClickShareSpaceShareLink(route: .spaceProfile)
        shareInviteLink = inviteLink
    }
    
    func onCopyLinkTap() {
        guard let inviteLink else { return }
        AnytypeAnalytics.instance().logClickShareSpaceCopyLink(route: .spaceProfile)
        UIPasteboard.general.string = inviteLink.absoluteString
        snackBarData = ToastBarData(Loc.copiedToClipboard(Loc.link), type: .success)
    }
    
    // MARK: - Private
    
    private func generateInviteIfPossible(spaceView: SpaceView) async {
        guard !linkUpdated else { return }
        defer { linkUpdated = true }
        
        if spaceView.uxType.isStream {
            guard let invite = try? await workspaceService.getGuestInvite(spaceId: workspaceInfo.accountSpaceId) else { return }
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } else {
            guard let invite = try? await workspaceService.getCurrentInvite(spaceId: workspaceInfo.accountSpaceId) else { return }
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        }
    }
    
    private func startParticipantTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: workspaceInfo.accountSpaceId).values {
            self.participantSpaceView = participantSpaceView
            
            spaceIcon = participantSpaceView.spaceView.objectIconImage
            spaceName = participantSpaceView.spaceView.title
            spaceDescription = participantSpaceView.spaceView.description
            
            allowDelete = participantSpaceView.canBeDeleted
            allowLeave = participantSpaceView.canLeave
            
            updateSettingsInfo()
            await generateInviteIfPossible(spaceView: participantSpaceView.spaceView)
        }
    }
    
    
    private func startOwnerTask() async {
        for await participants in participantsSubscription.participantsPublisher.values {
            owner = participants.first { $0.isOwner }
            updateSettingsInfo()
        }
    }
    
    private func updateSettingsInfo() {
        guard let participantSpaceView else { return }
        settingsInfo = spaceSettingsInfoBuilder.build(workspaceInfo: workspaceInfo, details: participantSpaceView.spaceView, owner: owner) { [weak self] in
            self?.snackBarData = ToastBarData(Loc.copiedToClipboard($0))
        }
    }
}
