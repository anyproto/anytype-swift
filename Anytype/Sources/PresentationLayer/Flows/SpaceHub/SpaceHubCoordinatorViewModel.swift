import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore
import PhotosUI


struct SpaceHubNavigationItem: Hashable { }

@MainActor
@Observable
final class SpaceHubCoordinatorViewModel: SpaceHubModuleOutput {
    var showSpaceManager = false
    var showObjectIsNotAvailableAlert = false
    var profileData: ObjectInfo?
    var spaceProfileData: AccountInfo?
    var userWarningAlert: UserWarningAlert?
    var typeSearchForObjectCreationSpaceId: StringIdentifiable?
    var showSharingExtension = false
    var membershipTierId: IntIdentifiable?
    var showGalleryImport: GalleryInstallationData?
    var spaceJoinData: SpaceJoinModuleData?
    var membershipNameFinalizationData: MembershipTier?
    var showGlobalSearchData: GlobalSearchModuleData?
    var toastBarData: ToastBarData?
    var showSpaceShareData: SpaceShareData?
    var showSpaceMembersData: SpaceMembersData?
    var chatProvider = ChatActionProvider()
    var bookmarkScreenData: BookmarkScreenData?
    var spaceCreateData: SpaceCreateData?
    var showSpaceTypeForCreate = false
    var shouldScanQrCode = false
    var showAppSettings = false
    
    var photosItems: [PhotosPickerItem] = []
    var showPhotosPicker = false
    var cameraData: SimpleCameraData?
    var showFilesPicker = false
    
    @ObservationIgnored
    private var uploadSpaceId: String?
    
    var currentSpaceId: String?
    var spaceInfo: AccountInfo? {
        guard let currentSpaceId else { return nil }
        return workspaceStorage.spaceInfo(spaceId: currentSpaceId)
    }
    
    var fallbackSpaceId: String? {
        userDefaults.lastOpenedScreen?.spaceId ?? fallbackSpaceView?.targetSpaceId
    }
    
    private var fallbackSpaceView: SpaceView?
    
    var pathChanging: Bool = false
    var navigationPath = HomePath(initialPath: [SpaceHubNavigationItem()])
    @ObservationIgnored
    lazy var pageNavigation = PageNavigation(
        open: { [weak self] data in
            self?.showScreenSync(data: data)
        }, pushHome: { [weak self] in
            guard let self, let currentSpaceId else { return }
            navigationPath.push(HomeWidgetData(spaceId: currentSpaceId))
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

    @ObservationIgnored
    var keyboardDismiss: KeyboardDismiss?
    @ObservationIgnored
    var dismissAllPresented: DismissAllPresented?
    
    @Injected(\.appActionStorage) @ObservationIgnored
    private var appActionsStorage: AppActionStorage
    @Injected(\.accountManager) @ObservationIgnored
    private var accountManager: any AccountManagerProtocol
    @Injected(\.activeSpaceManager) @ObservationIgnored
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var workspaceStorage: any SpaceViewsStorageProtocol
    @Injected(\.userDefaultsStorage) @ObservationIgnored
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var typeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.defaultObjectCreationService) @ObservationIgnored
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.loginStateService) @ObservationIgnored
    private var loginStateService: any LoginStateServiceProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.userWarningAlertsHandler) @ObservationIgnored
    private var userWarningAlertsHandler: any UserWarningAlertsHandlerProtocol
    @Injected(\.legacyNavigationContext) @ObservationIgnored
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.spaceFileUploadService) @ObservationIgnored
    private var spaceFileUploadService: any SpaceFileUploadServiceProtocol
    @Injected(\.spaceHubPathUXTypeHelper) @ObservationIgnored
    private var spaceHubPathUXTypeHelper: any SpaceHubPathUXTypeHelperProtocol
    
    @ObservationIgnored
    private var needSetup = true
    
    init() { }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    func onPathChange() {
        if let editorData = navigationPath.lastPathElement as? EditorScreenData {
            userDefaults.lastOpenedScreen = .editor(editorData)
        } else if let widgetData = navigationPath.lastPathElement as? HomeWidgetData {
            userDefaults.lastOpenedScreen = .widgets(spaceId: widgetData.spaceId)
        } else if let chatData = navigationPath.lastPathElement as? ChatCoordinatorData {
            userDefaults.lastOpenedScreen = .chat(chatData)
        } else if let chatData = navigationPath.lastPathElement as? SpaceChatCoordinatorData {
            userDefaults.lastOpenedScreen = .spaceChat(chatData)
        } else {
            userDefaults.lastOpenedScreen = nil
        }
        
        if navigationPath.count == 1 {
            Task {
                currentSpaceId = nil
                try await activeSpaceManager.setActiveSpace(spaceId: nil)
            }
        }
    }
    
    // MARK: - Setup
    func setup() async {
        if needSetup {
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
        guard !loginStateService.isFirstLaunchAfterRegistration, appActionsStorage.action.isNil else { return }
        
        switch userDefaults.lastOpenedScreen {
        case .editor(let editorData):
            try? await showScreen(data: .editor(editorData))
        case .widgets(let spaceId):
            try? await showScreen(data: .widget(HomeWidgetData(spaceId: spaceId)))
        case .chat(let data):
            try? await showScreen(data: .chat(data))
        case .spaceChat(let data):
            try? await showScreen(data: .spaceChat(data))
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
        for await info in activeSpaceManager.workspaceInfoStream {
            await handleActiveSpace(info: info)
        }
    }
    
    private func startHandleSpaceInfo() async {
        for await spaces in participantSpacesStorage.activeParticipantSpacesPublisher.values {
            fallbackSpaceView = spaces.first?.spaceView
        }
    }
    
    func startHandleMembershipStatus() async {
        for await membership in Container.shared.membershipStatusStorage.resolve()
            .statusStream() {
                guard membership.status == .pendingRequiresFinalization else { continue }
                
                membershipNameFinalizationData = membership.tier
            }
    }
    
    func handleVersionAlerts() async {
        userWarningAlert = userWarningAlertsHandler.getNextUserWarningAlertAndStore()
    }
    
    func onOpenBookmarkAsObject(_ data: BookmarkScreenData) {
        showScreenSync(data: .editor(data.editorScreenData))
    }
    
    func onSpaceTypeSelected(_ type: SpaceUxType) {
        Task {
            // After dismiss spaceCreateData, alert will appear again. Fix it.
            await dismissAllPresented?()
            spaceCreateData = SpaceCreateData(spaceUxType: type)
        }
    }
    
    func onSelectQrCodeScan() {
        shouldScanQrCode = true
    }
    
    func startSpaceSubscription() async {
        guard let spaceId = currentSpaceId else { return }
        for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
            navigationPath = await spaceHubPathUXTypeHelper.updateNaivgationPathForUxType(spaceView: spaceView, path: navigationPath)
        }
    }
    
    // MARK: - SpaceHubModuleOutput
    
    func onSelectCreateObject() {
        showSpaceTypeForCreate = true
    }
    
    func onSelectSpace(spaceId: String) {
        Task { try await openSpaceWithIntialScreen(spaceId: spaceId) }
    }
    
    func onOpenSpaceSettings(spaceId: String) {
        showScreenSync(data: .spaceInfo(.settings(spaceId: spaceId)))
    }
    
    func onSelectAppSettings() {
        showAppSettings = true
    }
    
    func photosPickerFinished() {
        defer { photosItems = [] }
        guard let uploadSpaceId else { return }
        spaceFileUploadService.uploadPhotoItems(photosItems, spaceId: uploadSpaceId)
    }
    
    func onAddMediaSelected(spaceId: String) {
        uploadSpaceId = spaceId
        showPhotosPicker = true
    }
    
    func onCameraSelected(spaceId: String) {
        uploadSpaceId = spaceId
        cameraData = SimpleCameraData(onMediaTaken: { [weak self] mediaType in
            guard let self, let uploadSpaceId else { return }
            spaceFileUploadService.uploadImagePickerMedia(type: mediaType, spaceId: uploadSpaceId)
        })
    }
    
    func onAddFilesSelected(spaceId: String) {
        uploadSpaceId = spaceId
        showFilesPicker = true
    }
    
    func fileImporterFinished(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            guard let uploadSpaceId else { return }
            spaceFileUploadService.uploadFiles(files, spaceId: uploadSpaceId)
        case .failure:
            break
        }
    }
    
    // MARK: - Private

    func typeSearchForObjectCreationModule(spaceId: String) -> TypeSearchForNewObjectCoordinatorView {
        TypeSearchForNewObjectCoordinatorView(spaceId: spaceId) { [weak self] details in
            guard let self else { return }
            showScreenSync(data: details.screenData())
        }
    }
    
    // MARK: - Navigation
    
    private func showScreenSync(data: ScreenData) {
        Task { try await showScreen(data: data) }
    }
    
    private func openSpaceWithIntialScreen(spaceId: String) async throws {
        let spaceView = try await setActiveSpace(spaceId: spaceId)
        if spaceView.initialScreenIsChat {
            let chatData = SpaceChatCoordinatorData(spaceId: spaceView.targetSpaceId)
            try await showScreen(data: .spaceChat(chatData))
        } else {
            let widgetData = HomeWidgetData(spaceId: spaceView.targetSpaceId)
            try await showScreen(data: .widget(widgetData))
        }
    }
    
    private func showScreen(data: ScreenData) async throws {
        
        if let objectId = data.objectId { // validate in case of object
            let document = documentsProvider.document(objectId: objectId, spaceId: data.spaceId, mode: .preview)
            try await document.open()
            guard let details = document.details else { return }
            guard details.isSupportedForOpening else {
                toastBarData = ToastBarData(Loc.openTypeError(details.objectType.displayName), type: .neutral)
                return
            }
        }
        
        let setupNewPath = currentSpaceId != data.spaceId
        let spaceView = try await setActiveSpace(spaceId: data.spaceId)
        var currentPath = setupNewPath ? HomePath(initialPath: initialHomePath(spaceView: spaceView)) : navigationPath
        
        await dismissAllPresented?()
        
        switch data {
        case .alert(let alertScreenData):
            await showAlert(alertScreenData)
        case .preview(let mediaFileScreenData):
            await showMediaFile(mediaFileScreenData)
        case .editor(let editorScreenData):
            currentPath.push(editorScreenData)
        case .bookmark(let data):
            await dismissAllPresented?()
            bookmarkScreenData = data
        case .spaceInfo(let data):
            guard let spaceView = participantSpacesStorage.participantSpaceView(spaceId: data.spaceId) else {
                return
            }
            
            if spaceView.canEdit {
                currentPath.push(data)
            } else {
                await dismissAllPresented?()
                spaceProfileData = spaceInfo
            }
        case .chat(let data):
            currentPath.openOnce(data)
        case .spaceChat(let data):
            currentPath.openOnce(data)
        case .widget(let data):
            let data = HomeWidgetData(spaceId: data.spaceId)
            currentPath.openOnce(data)
        }
        
        if navigationPath != currentPath {
            navigationPath = currentPath
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
            sourceView: data.sourceView,
            route: data.route
        )
        navigationContext.present(previewController) { [weak previewController] in
            previewController?.didFinishTransition = true
        }
        if (0..<data.items.count).contains(data.startAtIndex) {
            let item = data.items[data.startAtIndex]
            let type = item.fileDetails.fileContentType.analyticsValue
            AnytypeAnalytics.instance().logScreenMedia(type: type)
        }
    }
    
    private func setActiveSpace(spaceId: String) async throws -> SpaceView {
        // Check if space is deleted
        guard let spaceView = workspaceStorage.spaceView(spaceId: spaceId) else {
            currentSpaceId = nil
            try await activeSpaceManager.setActiveSpace(spaceId: nil)
            throw CommonError.undefined
        }
        
        guard currentSpaceId != spaceId else { return spaceView }
        
        currentSpaceId = spaceId
        
        // This is not required. But it help to load space as fast as possible
        Task { try await activeSpaceManager.setActiveSpace(spaceId: spaceId) }
        
        return spaceView
    }
    
    private func handleActiveSpace(info: AccountInfo?) async {
        guard info?.accountSpaceId != currentSpaceId else { return }
        
        if let info {
            do {
                try await openSpaceWithIntialScreen(spaceId: info.accountSpaceId)
            } catch {
                await dismissAllPresented?()
                navigationPath.popToRoot()
            }
        } else {
            await dismissAllPresented?()
            navigationPath.popToRoot()
        }
    }
    
    private func initialHomePath(spaceView: SpaceView) -> [AnyHashable] {
        .builder {
            SpaceHubNavigationItem()
            if spaceView.initialScreenIsChat {
                SpaceChatCoordinatorData(spaceId: spaceView.targetSpaceId)
            } else {
                HomeWidgetData(spaceId: spaceView.targetSpaceId)
            }
        }
    }

    // MARK: - App Actions
    private func handleAppAction(action: AppAction) async throws {
        keyboardDismiss?()
        await dismissAllPresented?()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            await createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .openObject(let objectId, let spaceId):
            try await handleOpenObject(objectId: objectId, spaceId: spaceId)
        case .deepLink(let deepLink, let source):
            try await handleDeepLink(deepLink: deepLink, source: source)
        }
    }
        
    private func handleDeepLink(deepLink: DeepLink, source: DeepLinkSource) async throws {
        switch deepLink {
        case .createObjectFromWidget:
            createAndShowDefaultObject(route: .widget)
        case .showSharingExtension:
            showSharingExtension = true
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key)
        case let .object(objectId, spaceId, cid, key):
            await handleObjectDeelpink(objectId: objectId, spaceId: spaceId, cid: cid, key: key, source: source)
        case .membership(let tierId):
            guard accountManager.account.allowMembership else { return }
            membershipTierId = tierId.identifiable
        case .networkConfig:
            toastBarData = ToastBarData(Loc.unsupportedDeeplink)
        }
    }
    
    private func handleObjectDeelpink(objectId: String, spaceId: String, cid: String?, key: String?, source: DeepLinkSource) async {
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        let route = source.isExternal ? OpenObjectByLinkRoute.web : OpenObjectByLinkRoute.app
        do {
            try await document.open()
            guard let editorData = document.details?.screenData() else { return }
            try? await showScreen(data: editorData)
            AnytypeAnalytics.instance().logOpenObjectByLink(type: .object, route: route)
        } catch {
            guard let cid, let key else {
                showObjectIsNotAvailableAlert = true
                AnytypeAnalytics.instance().logOpenObjectByLink(type: .notShared, route: route)
                return
            }
            
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key)
            AnytypeAnalytics.instance().logOpenObjectByLink(type: .invite, route: route)
        }
    }
    
    private func handleOpenObject(objectId: String, spaceId: String) async throws {
        guard let spaceView = workspaceStorage.spaceView(spaceId: spaceId) else { return }
        if spaceView.chatId == objectId, spaceView.initialScreenIsChat {
            try await showScreen(data: .spaceChat(SpaceChatCoordinatorData(spaceId: spaceId)))
        } else {
            let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
            try await document.open()
            guard let editorData = document.details?.screenData() else { return }
            try await showScreen(data: editorData)
        }
    }
    
    // MARK: - Object creation
    private func createAndShowNewObject(
        typeId: String,
        route: AnalyticsEventsRouteKind
    ) async {
        do {
            if fallbackSpaceId != currentSpaceId {
                // Set active spaces to receive types
                try await activeSpaceManager.setActiveSpace(spaceId: fallbackSpaceId)
            }
            let type = try typeProvider.objectType(id: typeId)
            try await createAndShowNewObject(type: type, route: route)
        } catch {
            anytypeAssertionFailure("No object provided typeId", info: ["typeId": typeId])
            createAndShowDefaultObject(route: route)
        }
    }
    
    private func createAndShowNewObject(
        type: ObjectType,
        route: AnalyticsEventsRouteKind
    ) async throws {
        let details = try await objectActionsService.createObject(
            name: "",
            typeUniqueKey: type.uniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: false,
            shouldSelectTemplate: true,
            spaceId: type.spaceId,
            origin: .none,
            templateId: type.defaultTemplateId
        )
        AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
        
        showScreenSync(data: details.screenData())
    }
    
    
    private func createAndShowDefaultObject(route: AnalyticsEventsRouteKind) {
        guard let fallbackSpaceId else { return }
        
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: fallbackSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            showScreenSync(data: details.screenData())
        }
    }
}

extension SpaceHubCoordinatorViewModel: HomeBottomNavigationPanelModuleOutput {
    func onSearchSelected() {
        guard let spaceInfo else { return }
        
        showGlobalSearchData = GlobalSearchModuleData(
            spaceId: spaceInfo.accountSpaceId,
            onSelect: { [weak self] screenData in
                self?.showScreenSync(data: screenData)
            }
        )
    }
    
    func onCreateObjectSelected(screenData: ScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        showScreenSync(data: screenData)
    }

    func popToFirstInSpace() {
        guard !pathChanging else { return }
        navigationPath.popToFirstOpened()
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
        showSpaceShareData = SpaceShareData(spaceId: spaceInfo.accountSpaceId, route: .navigation)
    }
    
    func onAddAttachmentToSpaceLevelChat(attachment: ChatLinkObject) {
        AnytypeAnalytics.instance().logClickQuote()
        chatProvider.addAttachment(attachment, clearInput: true)
        popToFirstInSpace()
    }
}
