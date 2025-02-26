import Foundation
import Combine
import Services
import UIKit
import AnytypeCore


@MainActor
final class NewSpaceSettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.spaceSettingsInfoBuilder)
    private var spaceSettingsInfoBuilder: any SpaceSettingsInfoBuilderProtocol
    
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)
    
    private let dateFormatter = DateFormatter.relativeDateFormatter
    private let storageInfoBuilder = SegmentInfoBuilder()
    private weak var output: (any NewSpaceSettingsModuleOutput)?
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    
    @Published var spaceIcon: Icon?
    
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData = ToastBarData.empty
    @Published var showSpaceDeleteAlert = false
    @Published var showSpaceLeaveAlert = false
    @Published var showInfoView = false
    @Published var dismiss = false
    @Published var allowDelete = false
    @Published var allowLeave = false
    @Published var allowEditSpace = false
    @Published var allowRemoteStorage = false
    @Published var shareSection: NewSpaceSettingsShareSection = .personal
    @Published var membershipUpgradeReason: MembershipUpgradeReason?
    @Published var shareInviteLink: URL?
    @Published var qrInviteLink: URL?
    @Published var storageInfo = RemoteStorageSegmentInfo()
    @Published var defaultObjectType: ObjectType?
    @Published var showIconPickerSpaceId: StringIdentifiable?
    
    let workspaceInfo: AccountInfo
    private var participantSpaceView: ParticipantSpaceViewData?
    private var joiningCount: Int = 0
    private var owner: Participant?
    private var inviteLink: URL?
    
    private var middlewareSpaceName = ""
    private var middlewareSpaceDescription = ""
    private var didSetup = false
    var haveChanges: Bool {
        middlewareSpaceName != spaceName || middlewareSpaceDescription != spaceDescription
    }
    
    
    init(workspaceInfo: AccountInfo, output: (any NewSpaceSettingsModuleOutput)?) {
        self.workspaceInfo = workspaceInfo
        self.output = output
    }
    
    func onInfoTap() {
        showInfoView.toggle()
    }
    
    func onWallpaperTap() {
        output?.onWallpaperSelected()
    }
    
    func onDefaultObjectTypeTap() {
        output?.onDefaultObjectTypeSelected()
    }
    
    func onStorageTap() {
        output?.onRemoteStorageSelected()
    }
    
    func onDeleteTap() {
        AnytypeAnalytics.instance().logClickDeleteSpace(route: .settings)
        showSpaceDeleteAlert.toggle()
    }
    
    func onShareTap() {
        output?.onSpaceShareSelected()
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceIndex()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    func onMembersTap() {
        output?.onSpaceMembersSelected()
    }
    
    func onMembershipUpgradeTap() {
        AnytypeAnalytics.instance().logClickUpgradePlanTooltip(type: .sharedSpaces, route: .spaceSettings)
        membershipUpgradeReason = .numberOfSharedSpaces
    }
    
    func onInviteTap() {
        Task {
            try await generateInviteIfNeeded()
            shareInviteLink = inviteLink
        }
    }
    
    func onQRCodeTap() {
        Task {
            try await generateInviteIfNeeded()
            qrInviteLink = inviteLink
        }
    }
    
    func onChangeIconTap() {
        showIconPickerSpaceId = workspaceInfo.accountSpaceId.identifiable
    }
    
    func onSaveTap() {
        Task {
            try await workspaceService.workspaceSetDetails(
                spaceId: workspaceInfo.accountSpaceId,
                details: [
                    .name(spaceName),
                    .description(spaceDescription)
                ]
            )
            
            snackBarData = ToastBarData(text: Loc.Settings.updated, showSnackBar: true)
        }
    }
    
    func onObjectTypesTap() {
        output?.onObjectTypesSelected()
    }
    
    // MARK: - Subscriptions
    
    func startSubscriptions() async {
        async let storageTask: () = startStorageTask()
        async let joiningTask: () = startJoiningTask()
        async let participantTask: () = startParticipantTask()
        async let defaultTypeTask: () = startDefaultTypeTask()
        (_,_,_, _) = await (storageTask, joiningTask, participantTask, defaultTypeTask)
    }
    
    private func startStorageTask() async {
        for await nodeUsage in fileLimitsStorage.nodeUsage.values {
            storageInfo = storageInfoBuilder.build(spaceId: workspaceInfo.accountSpaceId, nodeUsage: nodeUsage)
        }
    }
    
    private func startJoiningTask() async {
        for await participants in participantsSubscription.participantsPublisher.values {
            joiningCount = participants.filter { $0.status == .joining }.count
            owner = participants.first { $0.isOwner }
            updateViewState()
        }
    }
    
    private func startParticipantTask() async {
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: workspaceInfo.accountSpaceId).values {
            self.participantSpaceView = participantSpaceView
            updateViewState()
        }
    }
    
    private func startDefaultTypeTask() async {
        for await defaultObjectType in objectTypeProvider.defaultObjectTypePublisher(spaceId: workspaceInfo.accountSpaceId).values {
            self.defaultObjectType = defaultObjectType
        }
    }
    
    // MARK: - Private
    
    private func updateViewState() {
        guard let participantSpaceView else { return }
        
        let spaceView = participantSpaceView.spaceView
        
        spaceIcon = spaceView.objectIconImage
        allowDelete = participantSpaceView.canBeDeleted
        allowLeave = participantSpaceView.canLeave
        allowEditSpace = participantSpaceView.canEdit
        allowRemoteStorage = participantSpaceView.isOwner
        info = spaceSettingsInfoBuilder.build(workspaceInfo: workspaceInfo, details: spaceView, owner: owner) { [weak self] in
            self?.snackBarData = .init(text: Loc.copiedToClipboard($0), showSnackBar: true)
        }
        
        middlewareSpaceName = spaceView.name
        middlewareSpaceDescription = spaceView.description
        
        if !didSetup {
            spaceName = spaceView.name
            spaceDescription = spaceView.description
            didSetup = true
        }
        
        shareSection = buildShareSection(participantSpaceView: participantSpaceView)
        
        Task { try await generateInviteIfNeeded() }
    }
    
    private func buildShareSection(participantSpaceView: ParticipantSpaceViewData) -> NewSpaceSettingsShareSection {
        if participantSpaceView.canEdit {
            switch participantSpaceView.spaceView.spaceAccessType {
            case .personal, .UNRECOGNIZED, .none:
                return .personal
            case .private:
                guard participantSpaceView.canBeShared, let spaceSharingInfo = participantSpacesStorage.spaceSharingInfo else {
                    return .private(state: .unshareable)
                }
                
                if spaceSharingInfo.limitsAllowSharing {
                    return .private(state: .shareable)
                } else {
                    return .private(state: .reachedSharesLimit(limit: spaceSharingInfo.sharedSpacesLimit))
                }
            case .shared:
                return .ownerOrEditor(joiningCount: joiningCount)
            }
        } else {
            return .viewer
        }
    }
    
    private func generateInviteIfNeeded() async throws {
        if shareSection.isSharingAvailable && inviteLink.isNil {
            let invite = try await workspaceService.getCurrentInvite(spaceId: workspaceInfo.accountSpaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        }
    }
}
