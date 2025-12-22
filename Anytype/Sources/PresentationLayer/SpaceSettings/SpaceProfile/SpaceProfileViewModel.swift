import SwiftUI
import Services
import AnytypeCore


@MainActor
@Observable
final class SpaceProfileViewModel {
    var spaceName = ""
    var spaceDescription = ""
    var spaceIcon: Icon?

    var allowDelete = false
    var allowLeave = false

    var showInfoView = false
    var showSpaceDeleteAlert = false
    var showSpaceLeaveAlert = false

    var settingsInfo = [SettingsInfoModel]()
    var snackBarData: ToastBarData?

    var shareInviteLink: URL?
    var qrInviteLink: URL?
    var inviteLink: URL?

    let workspaceInfo: AccountInfo

    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.spaceSettingsInfoBuilder)
    private var spaceSettingsInfoBuilder: any SpaceSettingsInfoBuilderProtocol

    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol

    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)

    @ObservationIgnored
    private var owner: Participant?
    @ObservationIgnored
    private var participantSpaceView: ParticipantSpaceViewData?
    @ObservationIgnored
    private var linkUpdated: Bool = false
    
    init(info: AccountInfo) {
        self.workspaceInfo = info
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
