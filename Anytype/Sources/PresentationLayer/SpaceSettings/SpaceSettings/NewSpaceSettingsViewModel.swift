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
    
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)
    
    private let dateFormatter = DateFormatter.relativeDateFormatter
    private let storageInfoBuilder = SegmentInfoBuilder()
    private weak var output: (any NewSpaceSettingsModuleOutput)?
    
    // MARK: - State
    
    let workspaceInfo: AccountInfo
    private var participantSpaceView: ParticipantSpaceViewData?
    private var joiningCount: Int = 0
    private var owner: Participant?
    private var inviteLink: URL?
    
    var spaceDisplayName: String {
        spaceName.isNotEmpty ? spaceName : Loc.untitled
    }
    
    var spaceDisplayDescription: String {
        spaceDescription.isNotEmpty ? spaceDescription : spaceAccessType
    }
    
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    @Published var spaceAccessType = ""
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
    @Published var shareSection: SpaceSettingsShareSection = .personal
    @Published var membershipUpgradeReason: MembershipUpgradeReason?
    @Published var shareInviteLink: URL?
    @Published var qrInviteLink: URL?
    @Published var storageInfo = RemoteStorageSegmentInfo()
    @Published var defaultObjectType: ObjectType?
    
    init(workspaceInfo: AccountInfo, output: (any NewSpaceSettingsModuleOutput)?) {
        self.workspaceInfo = workspaceInfo
        self.output = output
    }
    
    func onSpaceDetailsTap() {
        output?.onSpaceDetailsSelected()
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
        spaceAccessType = spaceView.spaceAccessType?.name ?? ""
        spaceName = spaceView.name
        spaceDescription = spaceView.description
        allowDelete = participantSpaceView.canBeDeleted
        allowLeave = participantSpaceView.canLeave
        allowEditSpace = participantSpaceView.canEdit
        allowRemoteStorage = participantSpaceView.isOwner
        buildInfoBlock(details: spaceView)
        
        if participantSpaceView.isOwner {
            switch participantSpaceView.spaceView.spaceAccessType {
            case .personal, .UNRECOGNIZED, .none:
                shareSection = .personal
            case .private:
                guard participantSpaceView.canBeShared, let spaceSharingInfo = participantSpacesStorage.spaceSharingInfo else {
                    shareSection = .private(state: .unshareable)
                    break
                }
                
                if spaceSharingInfo.limitsAllowSharing {
                    shareSection = .private(state: .shareable)
                } else {
                    shareSection = .private(state: .reachedSharesLimit(limit: spaceSharingInfo.sharedSpacesLimit))
                }
            case .shared:
                shareSection = .owner(joiningCount: joiningCount)
            }
        } else {
            shareSection = .member
        }
        
        Task { try await generateInviteIfNeeded() }
    }
    
    private func buildInfoBlock(details: SpaceView) {
        
        info.removeAll()
        
        if let spaceRelationDetails = try? relationDetailsStorage.relationsDetails(bundledKey: .spaceId, spaceId: workspaceInfo.accountSpaceId) {
            info.append(
                SettingsInfoModel(title: spaceRelationDetails.name, subtitle: details.targetSpaceId, onTap: { [weak self] in
                    UIPasteboard.general.string = details.targetSpaceId
                    self?.snackBarData = .init(text: Loc.copiedToClipboard(spaceRelationDetails.name), showSnackBar: true)
                })
            )
        }
        
        if let creatorDetails = try? relationDetailsStorage.relationsDetails(bundledKey: .creator, spaceId: workspaceInfo.accountSpaceId) {
            
            if let owner {
                let displayName = owner.globalName.isNotEmpty ? owner.globalName : owner.identity
                
                info.append(
                    SettingsInfoModel(title: creatorDetails.name, subtitle: displayName, onTap: { [weak self] in
                        guard let self else { return }
                        UIPasteboard.general.string = displayName
                        snackBarData = .init(text: Loc.copiedToClipboard(creatorDetails.name), showSnackBar: true)
                    })
                )
            }
        }
        
        info.append(
            SettingsInfoModel(title: Loc.SpaceSettings.networkId, subtitle: workspaceInfo.networkId, onTap: { [weak self] in
                guard let self else { return }
                UIPasteboard.general.string = workspaceInfo.networkId
                snackBarData = .init(text: Loc.copiedToClipboard(Loc.SpaceSettings.networkId), showSnackBar: true)
            })
        )
        
        if let createdDateDetails = try? relationDetailsStorage.relationsDetails(bundledKey: .createdDate, spaceId: workspaceInfo.accountSpaceId),
           let date = details.createdDate.map({ dateFormatter.string(from: $0) }) {
            info.append(
                SettingsInfoModel(title: createdDateDetails.name, subtitle: date)
            )
        }
    }
    
    private func generateInviteIfNeeded() async throws {
        if shareSection.isSharingAvailable && inviteLink.isNil {
            let invite = try await workspaceService.getCurrentInvite(spaceId: workspaceInfo.accountSpaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        }
    }
}
