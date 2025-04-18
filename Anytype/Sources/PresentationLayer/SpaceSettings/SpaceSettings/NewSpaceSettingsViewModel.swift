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
    private let openedDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    
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
    @Published var isCreateTypeWidget: Bool? = nil
    @Published var shareSection: NewSpaceSettingsShareSection = .personal
    @Published var membershipUpgradeReason: MembershipUpgradeReason?
    @Published var storageInfo = RemoteStorageSegmentInfo()
    @Published var defaultObjectType: ObjectType?
    @Published var showIconPickerSpaceId: StringIdentifiable?
    @Published var editingData: SettingsInfoEditingViewData?
    @Published var shareInviteLink: URL?
    @Published var qrInviteLink: URL?
    @Published private(set) var inviteLink: URL?
    
    let workspaceInfo: AccountInfo
    private var participantSpaceView: ParticipantSpaceViewData?
    private var joiningCount: Int = 0
    private var owner: Participant?
    private let widgetsObject: any BaseDocumentProtocol
    
    var isChatOn: Bool? {
        guard FeatureFlags.showHomeSpaceLevelChat(spaceId: workspaceInfo.accountSpaceId) else { return nil }
        
        return switch participantSpaceView?.spaceView.uxType {
        case .chat:
            true
        case .data:
            false
        case .stream, .none, .UNRECOGNIZED:
            nil
        }
    }
    
    init(workspaceInfo: AccountInfo, output: (any NewSpaceSettingsModuleOutput)?) {
        self.workspaceInfo = workspaceInfo
        self.output = output
        self.widgetsObject = openedDocumentProvider.document(objectId: workspaceInfo.widgetsId, spaceId: workspaceInfo.accountSpaceId)
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
    
    func onObjectTypesTap() {
        output?.onObjectTypesSelected()
    }
    
    func toggleChatState(isOn: Bool) {
        Task {
            try await workspaceService.workspaceSetDetails(spaceId: workspaceInfo.accountSpaceId, details: [
                .spaceUxType(isOn ? .chat : .data)
            ])
            
            snackBarData = ToastBarData(text: isOn ? Loc.Settings.chatEnabled : Loc.Settings.chatDisabled, showSnackBar: true)
        }
    }
    
    func toggleCreateTypeWidgetState(isOn: Bool) {
        Task {
            AnytypeAnalytics.instance().logAutoCreateTypeWidgetToggle(value: isOn)
            try await objectActionsService.updateBundledDetails(contextID: workspaceInfo.widgetsId, details: [
                .autoWidgetDisabled(!isOn)
            ])
        }
    }

    func onTitleTap() {
        editingData = SettingsInfoEditingViewData(
            title: Loc.name,
            placeholder: Loc.untitled,
            initialValue: spaceName,
            font: .bodySemibold,
            onSave: { [weak self] in
                guard let self else { return }
                saveDetails(name: $0, description: spaceDescription)
            }
        )
    }
    
    func onDescriptionTap() {
        editingData = SettingsInfoEditingViewData(
            title: Loc.description,
            placeholder: Loc.addADescription,
            initialValue: spaceDescription,
            font: .previewTitle1Regular,
            onSave: { [weak self] in
                guard let self else { return }
                saveDetails(name: spaceName, description: $0)
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
        (_,_,_, _, _) = await (storageTask, joiningTask, participantTask, defaultTypeTask, widgetsObjectTask)
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
    
    private func startWidgetsObjectTask() async {
        for await _ in widgetsObject.detailsPublisher.values {
            updateViewState()
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
            
            snackBarData = ToastBarData(text: Loc.Settings.updated, showSnackBar: true)
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
        if participantSpaceView.isOwner, let widgetsDetails = widgetsObject.details {
            isCreateTypeWidget = !widgetsDetails.autoWidgetDisabled
        } else {
            isCreateTypeWidget = nil
        }
        
        info = spaceSettingsInfoBuilder.build(workspaceInfo: workspaceInfo, details: spaceView, owner: owner) { [weak self] in
            self?.snackBarData = .init(text: Loc.copiedToClipboard($0), showSnackBar: true)
        }
        
        spaceName = spaceView.name
        spaceDescription = spaceView.description
        
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
        guard let participantSpaceView else { return }
        guard shareSection.isSharingAvailable && inviteLink.isNil else { return }
        
        if participantSpaceView.spaceView.uxType.isStream {
            let invite = try await workspaceService.getGuestInvite(spaceId: workspaceInfo.accountSpaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        } else {
            let invite = try await workspaceService.getCurrentInvite(spaceId: workspaceInfo.accountSpaceId)
            inviteLink = universalLinkParser.createUrl(link: .invite(cid: invite.cid, key: invite.fileKey))
        }
    }
}
