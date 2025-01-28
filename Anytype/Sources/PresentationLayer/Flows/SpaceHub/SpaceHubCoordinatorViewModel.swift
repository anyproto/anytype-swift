import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore


struct SpaceHubNavigationItem: Hashable { }

@MainActor
final class SpaceHubCoordinatorViewModel: ObservableObject {
    @Published var showSpaceManager = false
    @Published var showSpaceShareTip = false
    @Published var showObjectIsNotAvailableAlert = false
    @Published var profileData: ObjectInfo?
    @Published var userWarningAlert: UserWarningAlert?
    @Published var typeSearchForObjectCreationSpaceId: StringIdentifiable?
    @Published var sharingSpaceId: StringIdentifiable?
    @Published var membershipTierId: IntIdentifiable?
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var spaceJoinData: SpaceJoinModuleData?
    @Published var membershipNameFinalizationData: MembershipTier?
    @Published var showGlobalSearchData: GlobalSearchModuleData?
    @Published var toastBarData = ToastBarData.empty
    @Published var showSpaceShareData: SpaceShareData?
    @Published var showSpaceMembersData: SpaceMembersData?
    @Published var chatProvider = ChatActionProvider()
    
    @Published var currentSpaceId: String?
    var spaceInfo: AccountInfo? {
        guard let currentSpaceId else { return nil }
        return workspaceStorage.workspaceInfo(spaceId: currentSpaceId)
    }
    
    var fallbackSpaceId: String? {
        userDefaults.lastOpenedScreen?.spaceId ?? fallbackSpaceView?.targetSpaceId
    }
    @Published private var fallbackSpaceView: SpaceView?
    
    @Published var pathChanging: Bool = false
    @Published var navigationPath = HomePath(initialPath: [SpaceHubNavigationItem()])
    lazy var pageNavigation = PageNavigation(
        open: { [weak self] data in
            self?.openSync(data: data)
        }, pushHome: { [weak self] in
            guard let self, let spaceInfo else { return }
            navigationPath.push(HomeWidgetData(info: spaceInfo))
        }, pop: { [weak self] in
            self?.navigationPath.pop()
        }, popToFirstInSpace: { [weak self] in
            self?.popToFirstInSpace()
        }, replace: { [weak self] data in
            guard let self else { return }
            if navigationPath.count > 1 {
                navigationPath.replaceLast(data)
            } else {
                navigationPath.push(data)
            }
        }
    )

    var keyboardDismiss: KeyboardDismiss?
    var dismissAllPresented: DismissAllPresented?
    
    let sceneId = UUID().uuidString
    
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.loginStateService)
    private var loginStateService: any LoginStateServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.userWarningAlertsHandler)
    private var userWarningAlertsHandler: any UserWarningAlertsHandlerProtocol
    @Injected(\.legacyNavigationContext)
    private var navigationContext: any NavigationContextProtocol
    
    private var needSetup = true
    
    init() { }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    func onPathChange() {
        if let editorData = navigationPath.lastPathElement as? EditorScreenData {
            userDefaults.lastOpenedScreen = .editor(editorData)
        } else if let spaceInfo = navigationPath.lastPathElement as? AccountInfo {
            userDefaults.lastOpenedScreen = .widgets(spaceId: spaceInfo.accountSpaceId)
        } else {
            userDefaults.lastOpenedScreen = nil
        }
        
        if navigationPath.count == 1 {
            Task { try await activeSpaceManager.setActiveSpace(spaceId: nil) }
        }
    }
    
    // MARK: - Setup
    func setup() async {
        if needSetup {
            await spaceSetupManager.registerSpaceSetter(sceneId: sceneId, setter: activeSpaceManager)
            await setupInitialScreen()
            await handleVersionAlerts()
            needSetup = false
        }
        
        await startSubscriptions()
    }
    
    func startSubscriptions() async {
        async let workspaceInfoSub: () = startHandleWorkspaceInfo()
        async let appActionsSub: () = startHandleAppActions()
        async let membershipSub: () = startHandleMembershipStatus()
        async let spaceInfoSub: () = startHandleSpaceInfo()
        (_,_,_,_) = await (workspaceInfoSub, appActionsSub, membershipSub, spaceInfoSub)
    }
    
    func setupInitialScreen() async {
        guard !loginStateService.isFirstLaunchAfterRegistration else { return }
        
        switch userDefaults.lastOpenedScreen {
        case .editor(let editorData):
            try? await open(data: .editor(editorData))
        case .widgets(let spaceId):
            try? await openSpace(spaceId: spaceId)
        case .none:
            return
        }
    }
    
    private func startHandleAppActions() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    private func startHandleWorkspaceInfo() async {
        activeSpaceManager.startSubscription()
        for await info in activeSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }
    
    private func startHandleSpaceInfo() async {
        for await spaces in participantSpacesStorage.activeParticipantSpacesPublisher.values {
            fallbackSpaceView = spaces.first?.spaceView
        }
    }
    
    func startHandleMembershipStatus() async {
        for await membership in Container.shared.membershipStatusStorage.resolve()
            .statusPublisher.values {
                guard membership.status == .pendingRequiresFinalization else { return }
                
                membershipNameFinalizationData = membership.tier
            }
    }
    
    func handleVersionAlerts() async {
        userWarningAlert = userWarningAlertsHandler.getNextUserWarningAlertAndStore()
    }
    
    // MARK: - Private

    func typeSearchForObjectCreationModule(spaceId: String) -> TypeSearchForNewObjectCoordinatorView {
        TypeSearchForNewObjectCoordinatorView(spaceId: spaceId) { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.screenData())
        }
    }
    
    // MARK: - Navigation
    private func openObject(screenData: ScreenData) {
        openSync(data: screenData)
    }
    
    private func openSync(data: ScreenData) {
        Task { try await open(data: data) }
    }
    
    private func open(data: ScreenData) async throws {
        if let objectId = data.objectId { // validate in case of object
            let document = documentsProvider.document(objectId: objectId, spaceId: data.spaceId, mode: .preview)
            try await document.open()
            guard let details = document.details else { return }
            guard details.isSupportedForOpening else {
                toastBarData = ToastBarData(
                    text: Loc.openTypeError(details.objectType.name), showSnackBar: true, messageType: .none
                )
                return
            }
        }
        
        let spaceId = data.spaceId
        try await openSpace(spaceId: spaceId, data: data)
    }
    
    private func openSpace(spaceId: String, data: ScreenData? = nil) async throws {
        guard currentSpaceId != spaceId else {
            try await showScreen(spaceId: spaceId, data: data)
            return
        }
        
        // Check if space is deleted
        guard let spaceView = workspaceStorage.spaceView(spaceId: spaceId) else { return }
        
        currentSpaceId = spaceId
        try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
        currentSpaceId = spaceId
        
        if let spaceInfo {
            navigationPath = HomePath(initialPath: initialHomePath(spaceView: spaceView, spaceInfo: spaceInfo))
            try await showScreen(spaceId: spaceId, data: data)
        }
    }
    
    private func showScreen(spaceId: String, data: ScreenData?) async throws {
        switch data {
        case .alert(let alertScreenData):
            if FeatureFlags.memberProfile {
                await showAlert(alertScreenData)
            } else { // fallback to page screen
                let pageObject = EditorPageObject(objectId: alertScreenData.objectId, spaceId: alertScreenData.spaceId)
                navigationPath.push(EditorScreenData.page(pageObject))
            }
        case .preview(let mediaFileScreenData):
            await showMediaFile(mediaFileScreenData)
        case .editor(let editorScreenData):
            navigationPath.push(editorScreenData)
        case nil:
            return
        }
    }
    
    private func showAlert(_ data: AlertScreenData) async {
        await dismissAllPresented?()
        
        switch data {
        case .spaceMember(let objectInfo):
            profileData = objectInfo
        }
    }
    
    private func showMediaFile(_ data: MediaFileScreenData) async {
        await dismissAllPresented?()
        let previewController = AnytypePreviewController(
            with: data.items,
            initialPreviewItemIndex: data.startAtIndex,
            sourceView: data.sourceView
        )
        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
    }
    
    private func switchSpace(info: AccountInfo?) {
        Task {
            guard currentSpaceId != info?.accountSpaceId else { return }
            
            currentSpaceId = info?.accountSpaceId
            
            if userWarningAlert.isNil {
                await dismissAllPresented?()
            }
            
            if let info, let spaceView = workspaceStorage.spaceView(spaceId: info.accountSpaceId) {
                let newPath = initialHomePath(spaceView: spaceView, spaceInfo: info)
                navigationPath = HomePath(initialPath: newPath)
            } else {
                navigationPath.popToRoot()
            }
        }
    }
    
    private func initialHomePath(spaceView: SpaceView, spaceInfo: AccountInfo) -> [AnyHashable] {
        .builder {
            SpaceHubNavigationItem()
            if spaceView.showChat {
                ChatCoordinatorData(chatId: spaceView.chatId, spaceInfo: spaceInfo)
            } else {
                HomeWidgetData(info: spaceInfo)
            }
        }
    }

    // MARK: - App Actions
    private func handleAppAction(action: AppAction) async throws {
        keyboardDismiss?()
        await dismissAllPresented?()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .deepLink(let deepLink):
            try await handleDeepLink(deepLink: deepLink)
        }
    }
        
    private func handleDeepLink(deepLink: DeepLink) async throws {
        switch deepLink {
        case .createObjectFromWidget:
            createAndShowDefaultObject(route: .widget)
        case .showSharingExtension:
            sharingSpaceId = fallbackSpaceId?.identifiable
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, sceneId: sceneId)
        case let .object(objectId, spaceId, cid, key):
            await handleObjectDeelpink(objectId: objectId, spaceId: spaceId, cid: cid, key: key)
        case .spaceShareTip:
            showSpaceShareTip = true
        case .membership(let tierId):
            guard accountManager.account.allowMembership else { return }
            membershipTierId = tierId.identifiable
        case .networkConfig:
            toastBarData = ToastBarData(text: Loc.unsupportedDeeplink, showSnackBar: true)
        }
    }
    
    private func handleObjectDeelpink(objectId: String, spaceId: String, cid: String?, key: String?) async {
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        do {
            try await document.open()
            guard let editorData = document.details?.screenData() else { return }
            try? await open(data: editorData)
        } catch {
            guard let cid, let key else {
                showObjectIsNotAvailableAlert = true
                return
            }
            
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, sceneId: sceneId)
        }
    }

    // MARK: - Object creation
    private func createAndShowNewObject(
        typeId: String,
        route: AnalyticsEventsRouteKind
    ) {
        do {
            let type = try typeProvider.objectType(id: typeId)
            createAndShowNewObject(type: type, route: route)
        } catch {
            anytypeAssertionFailure("No object provided typeId", info: ["typeId": typeId])
            createAndShowDefaultObject(route: route)
        }
    }
    
    private func createAndShowNewObject(
        type: ObjectType,
        route: AnalyticsEventsRouteKind
    ) {
        guard let fallbackSpaceId else { return }
        
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: fallbackSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            
            openObject(screenData: details.screenData())
        }
    }
    
    
    private func createAndShowDefaultObject(route: AnalyticsEventsRouteKind) {
        guard let fallbackSpaceId else { return }
        
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: fallbackSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            openObject(screenData: details.screenData())
        }
    }
}

extension SpaceHubCoordinatorViewModel: HomeBottomNavigationPanelModuleOutput {
    func onSearchSelected() {
        guard let spaceInfo else { return }
        
        showGlobalSearchData = GlobalSearchModuleData(
            spaceId: spaceInfo.accountSpaceId,
            onSelect: { [weak self] screenData in
                self?.openObject(screenData: screenData)
            }
        )
    }
    
    func onCreateObjectSelected(screenData: ScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func popToFirstInSpace() {
        guard !pathChanging else { return }
        navigationPath.popToFirstOpened()
    }

    func onForwardSelected() {
        guard !pathChanging else { return }
        navigationPath.pushFromHistory()
    }

    func onBackwardSelected() {
        guard !pathChanging else { return }
        navigationPath.pop()
    }
    
    func onPickTypeForNewObjectSelected() {
        guard let spaceInfo else { return }
        
        UISelectionFeedbackGenerator().selectionChanged()
        typeSearchForObjectCreationSpaceId = spaceInfo.accountSpaceId.identifiable
    }
    
    func onMembersSelected() {
        guard let spaceInfo else { return }
        showSpaceMembersData = SpaceMembersData(spaceId: spaceInfo.accountSpaceId, route: .navigation)
    }
    
    func onShareSelected() {
        guard let spaceInfo else { return }
        showSpaceShareData = SpaceShareData(workspaceInfo: spaceInfo, route: .navigation)
    }
    
    func onAddAttachmentToSpaceLevelChat(attachment: ChatLinkObject) {
        AnytypeAnalytics.instance().logClickQuote()
        chatProvider.addAttachment(attachment, clearInput: true)
        popToFirstInSpace()
    }
}
