import Foundation
import Services
@preconcurrency import Combine
import UIKit
import AnytypeCore
import Services

@MainActor
final class HomeBottomNavigationPanelViewModel: ObservableObject {
    
    enum LeftButtonMode {
        case member
        case owner(_ enable: Bool)
        case chat(_ enable: Bool)
        case home
    }
    
    private enum Constants {
        static let priorityTypesUniqueKeys: [ObjectTypeUniqueKey] = [.page, .note, .task]

    }
    
    // MARK: - Private properties
    private let info: AccountInfo
    
    @Injected(\.singleObjectSubscriptionService)
    private var subscriptionService: any SingleObjectSubscriptionServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.processSubscriptionService)
    private var processSubscriptionService: any ProcessSubscriptionServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    
    private weak var output: (any HomeBottomNavigationPanelModuleOutput)?
    private let subId = "HomeBottomNavigationProfile-\(UUID().uuidString)"
    
    private var activeProcess: Process?
    private var subscriptions: [AnyCancellable] = []
    private var chatLinkData: ChatLinkObject?
    private var isWidgetsScreen: Bool = false
    private var currentData: AnyHashable?
    private var participantSpaceView: ParticipantSpaceViewData?
    
    // MARK: - Public properties
    
    @Published var profileIcon: Icon?
    @Published var progress: Double? = nil
    @Published var leftButtonMode: LeftButtonMode?
    @Published var canCreateObject: Bool = false
    @Published var pageObjectType: ObjectType?
    @Published var noteObjectType: ObjectType?
    @Published var taskObjectType: ObjectType?
    @Published var otherObjectTypes: [ObjectType] = []
    
    init(
        info: AccountInfo,
        output: (any HomeBottomNavigationPanelModuleOutput)?
    ) {
        self.info = info
        self.output = output
        setupDataSubscription()
    }
    
    func onTapNewObject() {
        handleCreateObject()
    }
    
    func onTapSearch() {
        output?.onSearchSelected()
    }
    
    func onPlusButtonLongtap() {
        output?.onPickTypeForNewObjectSelected()
    }
    
    func startSubscriptions() async {
        async let participantSub: () = participantSubscription()
        async let typesSub: () = typesSubscription()
        
        (_, _) = await (participantSub, typesSub)
    }
    
    func updateVisibleScreen(data: AnyHashable) {
        chatLinkData = (data as? EditorScreenData)?.chatLink
        isWidgetsScreen = (data as? HomeWidgetData) != nil
        currentData = data
        updateState()
    }
    
    func onTapMembers() {
        output?.onMembersSelected()
    }
    
    func onTapShare() {
        output?.onShareSelected()
    }
    
    func onTapAddToSpaceLevelChat() {
        guard let chatLinkData else { return }
        output?.onAddAttachmentToSpaceLevelChat(attachment: chatLinkData)
    }
    
    func onTapHome() {
        output?.popToFirstInSpace()
    }
    
    func onTapCreateObject(type: ObjectType) {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(objectType: type.analyticsType, route: clickAddMenuAnalyticsRoute())
        Task { @MainActor in
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: true,
                shouldSelectTemplate: true,
                spaceId: info.accountSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .navigation)
            
            try? await objectActionsService.updateBundledDetails(contextID: type.id, details: [ .lastUsedDate(Date.now)])
            
            output?.onCreateObjectSelected(screenData: details.screenData())
        }
    }
    
    func onAddMediaSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .photo, route: clickAddMenuAnalyticsRoute())
        output?.onAddMediaSelected(spaceId: info.accountSpaceId)
    }
    
    func onCameraSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .camera, route: clickAddMenuAnalyticsRoute())
        output?.onCameraSelected(spaceId: info.accountSpaceId)
    }
    
    func onAddFilesSelected() {
        AnytypeAnalytics.instance().logClickNavBarAddMenu(type: .file, route: clickAddMenuAnalyticsRoute())
        output?.onAddFilesSelected(spaceId: info.accountSpaceId)
    }
    
    // MARK: - Private
    
    private func participantSubscription() async {
        for await data in participantSpacesStorage.participantSpaceViewPublisher(spaceId: info.accountSpaceId).values {
            participantSpaceView = data
            updateState()
        }
    }
    
    private func typesSubscription() async {
        for await types in objectTypeProvider.objectTypesPublisher(spaceId: info.accountSpaceId).values {
            let types = types.filter { type in
                DetailsLayout.supportedForCreation.contains { $0 == type.recommendedLayout }
                && !type.isTemplateType
            }
            
            // priority object types
            pageObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.page }
            noteObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.note }
            taskObjectType = types.first { $0.uniqueKey == ObjectTypeUniqueKey.task }

            // other object types (excluding Image and File types as per requirements)
            otherObjectTypes = types
                .filter {
                    !Constants.priorityTypesUniqueKeys.contains($0.uniqueKey) &&
                    $0.uniqueKey != .image &&
                    $0.uniqueKey != .file
                }
        }
    }
    
    private func updateState() {
        guard let participantSpaceView else { return }
        
        let canLinkToChat = chatLinkData.isNotNil && participantSpaceView.spaceView.initialScreenIsChat
        
        if canLinkToChat {
            leftButtonMode = .chat(participantSpaceView.permissions.canEdit)
        } else if isWidgetsScreen {
            if participantSpaceView.isOwner {
                let limitAllowSharing = participantSpacesStorage.spaceSharingInfo?.limitsAllowSharing ?? false
                let canBeShared = participantSpaceView.permissions.canBeShared
                let isShared = participantSpaceView.spaceView.isShared
                leftButtonMode = .owner(isShared || (limitAllowSharing && canBeShared))
            } else {
                leftButtonMode = .member
            }
        } else {
            leftButtonMode = .home
        }
        
        canCreateObject = participantSpaceView.permissions.canEdit
    }
    
    private func setupDataSubscription() {
        Task {
            await subscriptionService.startSubscription(
                subId: subId,
                spaceId: info.techSpaceId,
                objectId: info.profileObjectID
            ) { [weak self] details in
                await self?.handleProfileDetails(details: details)
            }
            
            await processSubscriptionService.addHandler { [weak self] events in
                await self?.handleProcesses(events: events)
            }.store(in: &subscriptions)
        }
    }
    
    private func handleProfileDetails(details: ObjectDetails) {
        profileIcon = details.objectIconImage
    }
    
    private func handleCreateObject() {
        Task { @MainActor in
            guard let details = try? await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: info.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .navigation)
            
            output?.onCreateObjectSelected(screenData: details.screenData())
        }
    }
    
    private func handleProcesses(events: [ProcessEvent]) {
        for event in events {
            switch event {
            case .new(let process):
                guard activeProcess.isNil else { return }
                activeProcess = process
                progress = Double(process.progress.done) / Double(process.progress.total)
            case .update(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = process
                progress = Double(process.progress.done) / Double(process.progress.total)
            case .done(let process):
                guard process.id == activeProcess?.id else { return }
                activeProcess = nil
                progress = Double(process.progress.done) / Double(process.progress.total)
                Task {
                    try await Task.sleep(seconds: 2)
                    // If other process not executing
                    if activeProcess.isNil {
                        progress = nil
                    }
                }
            }
        }
    }
    
    private func clickAddMenuAnalyticsRoute() -> ClickNavBarAddMenuRoute? {
        // Read before sending the event. This way we can keep track of which screens don't have a route.
        if let provider = currentData as? any HomeClinkNavBarAddMenuRouteProvider {
            return provider.clickNavBarAddMenuRoute
        }
        if let currentData {
            anytypeAssertionFailure("Home data without ClinkNavBarAddMenuRoute", info: ["type": "\(currentData)"])
        }
        return nil
    }
}
