import Foundation
import Services
import UIKit
import AnytypeCore


@MainActor
@Observable
final class SpaceSettingsViewModel {

    // MARK: - DI

    @ObservationIgnored @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    @ObservationIgnored @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @ObservationIgnored @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @ObservationIgnored @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored @Injected(\.mailUrlBuilder)
    private var mailUrlBuilder: any MailUrlBuilderProtocol
    @ObservationIgnored @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    @ObservationIgnored @Injected(\.fileLimitsStorage)
    private var fileLimitsStorage: any FileLimitsStorageProtocol
    @ObservationIgnored @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @ObservationIgnored @Injected(\.spaceSettingsInfoBuilder)
    private var spaceSettingsInfoBuilder: any SpaceSettingsInfoBuilderProtocol
    @ObservationIgnored
    private let openedDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    @ObservationIgnored @Injected(\.pushNotificationsSystemSettingsBroadcaster)
    private var pushNotificationsSystemSettingsBroadcaster: any PushNotificationsSystemSettingsBroadcasterProtocol

    @ObservationIgnored
    private lazy var participantsSubscription: any ParticipantsSubscriptionProtocol = Container.shared.participantSubscription(workspaceInfo.accountSpaceId)

    @ObservationIgnored
    private let dateFormatter = DateFormatter.relativeDateFormatter
    @ObservationIgnored
    private let storageInfoBuilder = SegmentInfoBuilder()
    @ObservationIgnored
    private weak var output: (any SpaceSettingsModuleOutput)?

    // MARK: - State

    var spaceName = ""
    var spaceDescription = ""
    var spaceIcon: Icon?

    var info = [SettingsInfoModel]()
    var participants: [Participant] = []
    var snackBarData: ToastBarData?
    var showSpaceDeleteAlert = false
    var showSpaceLeaveAlert = false
    var showInfoView = false
    var dismiss = false
    var allowDelete = false
    var allowLeave = false
    var allowRemoteStorage = false
    var uxTypeSettingsData: SpaceUxTypeSettingsData?
    var shareSection: SpaceSettingsShareSection = .personal
    var membershipUpgradeReason: MembershipUpgradeReason?
    var storageInfo = RemoteStorageSegmentInfo()
    var defaultObjectType: ObjectType?
    var showIconPickerSpaceId: StringIdentifiable?
    var editingData: SettingsInfoEditingViewData?
    var pushNotificationsSettingsMode: SpaceNotificationsSettingsMode = .allActiviy
    var pushNotificationsSettingsStatus: PushNotificationsSettingsStatus?
    var shareInviteLink: URL?
    var qrInviteLink: URL?
    private(set) var inviteLink: URL?
    var participantsCount: Int = 0
    var canAddWriters = true
    var joiningCount: Int = 0
    var isOneToOne = false

    let workspaceInfo: AccountInfo
    @ObservationIgnored
    private var participantSpaceView: ParticipantSpaceViewData?
    @ObservationIgnored
    private var owner: Participant?
    @ObservationIgnored
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
    
    func onUxTypeTap() {
        output?.onSpaceUxTypeSelected()
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
            self.participants = participants
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
        allowRemoteStorage = participantSpaceView.isOwner
        canAddWriters = spaceView.canAddWriters(participants: participants)
        isOneToOne = spaceView.uxType.isOneToOne

        uxTypeSettingsData = participantSpaceView.canChangeUxType && spaceView.hasChat && FeatureFlags.channelTypeSwitcher ? SpaceUxTypeSettingsData(uxType: spaceView.uxType) : nil

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
                if participantSpaceView.isOwner {
                    return .owner(joiningCount: joiningCount)
                } else {
                    return .editor
                }
            }
        } else {
            return .viewer
        }
    }
    
    private func updateInviteIfNeeded() async throws {
        guard let participantSpaceView else { return }
        guard shareSection.isSharingAvailable else { return }
        guard !participantSpaceView.spaceView.uxType.isOneToOne else { return }
        
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
