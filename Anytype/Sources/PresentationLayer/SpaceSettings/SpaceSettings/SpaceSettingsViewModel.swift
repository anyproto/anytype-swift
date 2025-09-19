import Foundation
import Combine
import Services
import UIKit
import AnytypeCore


@MainActor
final class SpaceSettingsViewModel: ObservableObject {
    
    // MARK: - DI
    
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
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
    private let openedDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol
    
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)
    
    private let dateFormatter = DateFormatter.relativeDateFormatter
    private let storageInfoBuilder = SegmentInfoBuilder()
    private weak var output: (any SpaceSettingsModuleOutput)?
    
    // MARK: - State
    
    @Published var spaceName = ""
    @Published var spaceDescription = ""
    @Published var spaceIcon: Icon?
    
    @Published var info = [SettingsInfoModel]()
    @Published var snackBarData: ToastBarData?
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
    @Published var storageInfo = RemoteStorageSegmentInfo()
    @Published var defaultObjectType: ObjectType?
    @Published var showIconPickerSpaceId: StringIdentifiable?
    @Published var editingData: SettingsInfoEditingViewData?
    @Published var pushNotificationsSettingsMode: SpaceNotificationsSettingsMode = .allActiviy
    @Published var pushNotificationsSettingsStatus: PushNotificationsSettingsStatus?
    @Published var shareInviteLink: URL?
    @Published var qrInviteLink: URL?
    @Published private(set) var inviteLink: URL?
    @Published var participantsCount: Int = 0
    
    let workspaceInfo: AccountInfo
    private var participantSpaceView: ParticipantSpaceViewData?
    private var joiningCount: Int = 0
    private var owner: Participant?
    private let widgetsObject: any BaseDocumentProtocol
    
    init(workspaceInfo: AccountInfo, output: (any SpaceSettingsModuleOutput)?) {
        self.workspaceInfo = workspaceInfo
        self.output = output
        self.widgetsObject = openedDocumentProvider.document(objectId: workspaceInfo.widgetsId, spaceId: workspaceInfo.accountSpaceId)
    }
    
    func onInfoTap() {
        showInfoView.toggle()
    }
    
    func onCopyTitleTap() {
        UIPasteboard.general.string = spaceName
        snackBarData = ToastBarData(Loc.copiedToClipboard(spaceName), type: .success)
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
    
    func onMembersTap() {
        output?.onSpaceShareSelected() { [weak self] in
            Task { try await self?.updateInviteIfNeeded() }
        }
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenSettingsSpaceIndex()
    }
    
    func onLeaveTap() {
        showSpaceLeaveAlert.toggle()
    }
    
    func onMembershipUpgradeTap() {
        AnytypeAnalytics.instance().logClickUpgradePlanTooltip(type: .sharedSpaces, route: .spaceSettings)
        membershipUpgradeReason = .numberOfSharedSpaces
    }
    
    func onNotificationsTap() {
        output?.onNotificationsSelected()
    }
    
    func onShareTap() {
        AnytypeAnalytics.instance().logClickShareSpaceShareLink(route: .spaceSettings)
        Task {
            try await updateInviteIfNeeded()
            shareInviteLink = inviteLink
        }
    }
    
    func onQRCodeTap() {
        Task {
            try await updateInviteIfNeeded()
            qrInviteLink = inviteLink
        }
    }
    
    func onCopyLinkTap() {
        Task {
            try await updateInviteIfNeeded()
            guard let inviteLink else { return }
            AnytypeAnalytics.instance().logClickShareSpaceCopyLink(route: .spaceSettings)
            UIPasteboard.general.string = inviteLink.absoluteString
            snackBarData = ToastBarData(Loc.copiedToClipboard(Loc.link), type: .success)
        }
    }
    
    func onChangeIconTap() {
        showIconPickerSpaceId = workspaceInfo.accountSpaceId.identifiable
    }
    
    func onObjectTypesTap() {
        output?.onObjectTypesSelected()
    }
    
    func onPropertiesTap() {
        output?.onPropertiesSelected()
    }

    func onEditTap() {
        editingData = SettingsInfoEditingViewData(
            title: Loc.name,
            placeholder: Loc.untitled,
            initialValue: spaceName,
            font: .bodySemibold,
            usecase: .spaceName,
            onSave: { [weak self] in
                guard let self else { return }
                saveDetails(name: $0, description: spaceDescription)
            }
        )
    }
    
    
    func onBinTap() {
        output?.onBinSelected()
    }
    
    // MARK: - Subscriptions
    
    func startSubscriptions() async {
        async let storageTask: () = startStorageTask()
        async let joiningTask: () = startJoiningTask()
        async let participantTask: () = startParticipantTask()
        async let defaultTypeTask: () = startDefaultTypeTask()
        async let widgetsObjectTask: () = startWidgetsObjectTask()
        async let systemSettingsChangesTask: () = startSystemSettingsChangesTask()
        (_,_,_,_,_,_) = await (storageTask, joiningTask, participantTask, defaultTypeTask, widgetsObjectTask, systemSettingsChangesTask)
    }
    
    private func startStorageTask() async {
        for await nodeUsage in fileLimitsStorage.nodeUsage.values {
            storageInfo = storageInfoBuilder.build(spaceId: workspaceInfo.accountSpaceId, nodeUsage: nodeUsage)
        }
    }
    
    private func startJoiningTask() async {
        for await participants in participantsSubscription.participantsPublisher.values {
            participantsCount = participants.filter { $0.status == .active }.count
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
    
    private func startWidgetsObjectTask() async {
        for await _ in widgetsObject.detailsPublisher.values {
            updateViewState()
        }
    }
    
    private func startSystemSettingsChangesTask() async {
        for await status in pushNotificationsSystemSettingsBroadcaster.statusStream {
            self.pushNotificationsSettingsStatus = status.asPushNotificationsSettingsStatus
        }
    }
    
    // MARK: - Private
    
    private func saveDetails(name: String, description: String) {
        Task {
            try await workspaceService.workspaceSetDetails(
                spaceId: workspaceInfo.accountSpaceId,
                details: [
                    .name(name),
                    .description(description)
                ]
            )
            
            snackBarData = ToastBarData(Loc.Settings.updated)
        }
    }
    
    private func updateViewState() {
        guard let participantSpaceView else { return }
        
        let spaceView = participantSpaceView.spaceView
        
        spaceIcon = spaceView.objectIconImage
        allowDelete = participantSpaceView.canBeDeleted
        allowLeave = participantSpaceView.canLeave
        allowEditSpace = participantSpaceView.canEdit
        allowRemoteStorage = participantSpaceView.isOwner
        
        info = spaceSettingsInfoBuilder.build(workspaceInfo: workspaceInfo, details: spaceView, owner: owner) { [weak self] in
            self?.snackBarData = ToastBarData(Loc.copiedToClipboard($0))
        }
        
        spaceName = spaceView.name
        spaceDescription = spaceView.description
        
        pushNotificationsSettingsMode = spaceView.pushNotificationMode.asNotificationsSettingsMode
        
        shareSection = buildShareSection(participantSpaceView: participantSpaceView)
        
        Task { try await updateInviteIfNeeded() }
    }
    
    private func buildShareSection(participantSpaceView: ParticipantSpaceViewData) -> SpaceSettingsShareSection {
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
    
    private func updateInviteIfNeeded() async throws {
        guard let participantSpaceView else { return }
        guard shareSection.isSharingAvailable else { return }
        
        if participantSpaceView.spaceView.uxType.isStream {
            let invite = try? await workspaceService.getGuestInvite(spaceId: workspaceInfo.accountSpaceId)
            if let invite {
                inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
            } else {
                inviteLink = nil
            }
        } else {
            let invite = try? await workspaceService.getCurrentInvite(spaceId: workspaceInfo.accountSpaceId)
            if let invite {
                inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
            } else {
                inviteLink = nil
            }
        }
    }
}
