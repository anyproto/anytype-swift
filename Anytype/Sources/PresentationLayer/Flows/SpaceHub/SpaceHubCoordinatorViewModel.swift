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
    var showSharedChannelLimit = false
    var sharedChannelLimit: Int = 0
    var membershipUpgradeReason: MembershipUpgradeReason?
    var showObjectIsNotAvailableAlert = false
    var profileData: ObjectInfo?
    var spaceProfileData: AccountInfo?
    var userWarningAlert: UserWarningAlert?
    var showSharingExtension = false
    var membershipTierId: IntIdentifiable?
    var showGalleryImport: GalleryInstallationData?
    var spaceJoinData: SpaceJoinModuleData?
    var membershipNameFinalizationData: MembershipTier?
    var showGlobalSearchData: GlobalSearchModuleData?
    var toastBarData: ToastBarData?
    var chatProvider = ChatActionProvider()
    var bookmarkScreenData: BookmarkScreenData?
    var spaceCreateData: SpaceCreateData?
    var chatCreateData: ChatCreateScreenData?
    var bookmarkCreateData: BookmarkCreateScreenData?
    var overlayWidgetsData: HomeWidgetData?
    var showSpaceTypeForCreate = false
    var showGroupChannelCreate = false
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
        fallbackSpaceView?.targetSpaceId
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
        },
        replaceHome: { [weak self] newData in
            guard let self, FeatureFlags.fixChannelHomeBackNavigation else { return }
            guard !pathChanging, let current = navigationPath.currentHome else { return }
            let isReplaceableHomeSlot =
                current is HomeWidgetData ||
                current is EditorScreenData ||
                current is ChatCoordinatorData
            guard isReplaceableHomeSlot else {
                anytypeAssertionFailure(
                    "replaceHome called with non-replaceable home slot",
                    info: ["currentType": "\(type(of: current))"]
                )
                return
            }
            guard current != newData else { return }
            navigationPath.replaceHome(newData)
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
    @Injected(\.objectTypeProvider) @ObservationIgnored
    private var typeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService) @ObservationIgnored
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.defaultObjectCreationService) @ObservationIgnored
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.userWarningAlertsHandler) @ObservationIgnored
    private var userWarningAlertsHandler: any UserWarningAlertsHandlerProtocol
    @Injected(\.legacyNavigationContext) @ObservationIgnored
    private var navigationContext: any NavigationContextProtocol
    @Injected(\.spaceFileUploadService) @ObservationIgnored
    private var spaceFileUploadService: any SpaceFileUploadServiceProtocol
    @Injected(\.workspaceService) @ObservationIgnored
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.searchService) @ObservationIgnored
    private var searchService: any SearchServiceProtocol
    @Injected(\.contactsService) @ObservationIgnored
    private var contactsService: any ContactsServiceProtocol
    @Injected(\.pendingShareService) @ObservationIgnored
    private var pendingShareService: any PendingShareServiceProtocol
    @Injected(\.pendingShareStorage) @ObservationIgnored
    private var pendingShareStorage: any PendingShareStorageProtocol
    @ObservationIgnored
    private var needSetup = true
    
    init() { }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    func onPathChange() {
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
            await handleVersionAlerts()
            needSetup = false
        }

        if FeatureFlags.createChannelFlow {
            Task { await contactsService.prefetch() }
        }
        await startSubscriptions()
    }
    
    func startSubscriptions() async {
        async let workspaceInfoSub: () = startHandleWorkspaceInfo()
        async let appActionsSub: () = startHandleAppActions()
        async let membershipSub: () = startHandleMembershipStatus()
        async let spaceInfoSub: () = startHandleSpaceInfo()
        async let shareRetrySub: () = startHandlePendingShareRetry()
        (_,_,_,_,_) = await (workspaceInfoSub, appActionsSub, membershipSub, spaceInfoSub, shareRetrySub)
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

    private func startHandlePendingShareRetry() async {
        guard FeatureFlags.fixChannelHomeBackNavigation else { return }
        var innerTask: Task<Void, Never>?
        for await info in activeSpaceManager.workspaceInfoStream {
            innerTask?.cancel()
            let spaceId = info?.accountSpaceId ?? ""
            guard !spaceId.isEmpty,
                  pendingShareStorage.pendingState(for: spaceId) != nil else {
                innerTask = nil
                continue
            }
            innerTask = Task { [weak self] in
                guard let self else { return }
                for await participantSpaceView in participantSpacesStorage
                    .participantSpaceViewPublisher(spaceId: spaceId).values {
                    guard !Task.isCancelled else { return }
                    guard pendingShareStorage.pendingState(for: spaceId) != nil else { return }
                    if participantSpaceView.spaceView.isActive {
                        await pendingShareService.retryIfNeeded(spaceId: spaceId)
                    }
                }
            }
        }
        innerTask?.cancel()
    }
    
    func startHandleMembershipStatus() async {
        for await membership in Container.shared.membershipStatusStorage.resolve()
            .statusPublisher.values {
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
        Task {
            await dismissAllPresented?()
            shouldScanQrCode = true
        }
    }
    
    // MARK: - SpaceHubModuleOutput
    
    func onSelectCreateObject() {
        showSpaceTypeForCreate = true
    }

    func onSelectCreatePersonalChannel() {
        spaceCreateData = SpaceCreateData(spaceUxType: .data, channelType: .personal)
    }

    func onSelectCreateGroupChannel() {
        let spaceSharingInfo = participantSpacesStorage.spaceSharingInfo
        if let spaceSharingInfo, !spaceSharingInfo.limitsAllowSharing {
            sharedChannelLimit = spaceSharingInfo.sharedSpacesLimit
            showSharedChannelLimit = true
        } else {
            showGroupChannelCreate = true
        }
    }

    func onSharedChannelLimitUpgrade() {
        showSharedChannelLimit = false
        membershipUpgradeReason = .numberOfSharedSpaces
    }

    func onSharedChannelLimitManageChannels() {
        showSharedChannelLimit = false
        showSpaceManager = true
    }

    func onSelectQrCodeJoin() {
        Task {
            await dismissAllPresented?()
            shouldScanQrCode = true
        }
    }
    
    func onSelectSpace(spaceId: String) {
        Task { await showSpace(spaceId: spaceId) }
    }

    func onSpaceJoined(spaceId: String, spaceUxType: SpaceUxType) {
        Task { await showSpace(spaceId: spaceId, spaceUxType: spaceUxType) }
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
    
    // MARK: - Navigation
    
    private func showScreenSync(data: ScreenData) {
        Task { try await showScreen(data: data) }
    }
    
    private func homeObjectScreenData(spaceId: String, spaceUxType: SpaceUxType? = nil) async -> AnyHashable {
        let spaceView = workspaceStorage.spaceView(spaceId: spaceId)

        // 1-1 spaces always open on chat
        let isOneToOne = spaceUxType == .oneToOne || spaceView?.isOneToOne == true
        if isOneToOne {
            return SpaceChatCoordinatorData(spaceId: spaceId)
        }

        // Read homepage from middleware-synced SpaceView
        let homepage = spaceView?.homepage ?? .empty

        switch homepage {
        case .empty, .widgets, .graph:
            return HomeWidgetData(spaceId: spaceId)
        case .object(let objectId):
            let details = try? await searchService.searchObjects(spaceId: spaceId, objectIds: [objectId]).first
            if let details, !details.isArchivedOrDeleted {
                switch details.screenData() {
                case .editor(let editorData):
                    return editorData
                case .chat(let chatData):
                    return chatData
                case .discussion(let discussionData):
                    return discussionData
                default:
                    break
                }
            }
            // Fallback: object not found or deleted → widgets
            return HomeWidgetData(spaceId: spaceId)
        }
    }

    /// Builds the home path for a space without committing to navigationPath.
    /// Returns nil if already in the target space.
    private func prepareSpacePath(spaceId: String, spaceUxType: SpaceUxType? = nil) async -> HomePath? {
        guard currentSpaceId != spaceId else { return nil }

        setActiveSpace(spaceId: spaceId)
        let homeObject = await homeObjectScreenData(spaceId: spaceId, spaceUxType: spaceUxType)

        let path: [AnyHashable] = .builder {
            SpaceHubNavigationItem()
            homeObject
        }

        return HomePath(initialPath: path)
    }

    private func showSpace(spaceId: String, spaceUxType: SpaceUxType? = nil) async {
        guard let newPath = await prepareSpacePath(spaceId: spaceId, spaceUxType: spaceUxType) else { return }
        if navigationPath != newPath {
            await dismissAllPresented?()
            navigationPath = newPath
        }
    }

    // main show screen logic
    private func showScreen(data: ScreenData) async throws {
        guard try await checkIsDataSupportedForOpening(data) else { return }

        // Build space path without committing — showScreen will commit once with final state
        var currentPath: HomePath
        let isSwitchingSpace: Bool
        if let spacePath = await prepareSpacePath(spaceId: data.spaceId) {
            currentPath = spacePath
            isSwitchingSpace = true
        } else {
            currentPath = navigationPath
            isSwitchingSpace = false
        }

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
            // 1-1 spaces: home screen is SpaceChatCoordinatorData (chatId resolved at view time).
            if let existingData = currentPath.path.lazy.compactMap({ $0.base as? SpaceChatCoordinatorData }).first(where: { $0.spaceId == data.spaceId }) {
                currentPath.popTo(existingData)
                if let messageId = data.messageId {
                    if isSwitchingSpace {
                        // Space is being opened fresh — include messageId in path data
                        currentPath.replaceLast(SpaceChatCoordinatorData(spaceId: data.spaceId, messageId: messageId))
                    } else {
                        // Chat already on screen — scroll via provider without recreating
                        chatProvider.scrollToMessage(chatId: data.chatId, messageId: messageId)
                    }
                }
            // Channel/stream spaces: home screen is ChatCoordinatorData (chatId known at build time).
            // Match by chatId because multiple chats can exist in one space.
            } else if let existingChat = currentPath.path.lazy.compactMap({ $0.base as? ChatCoordinatorData }).first(where: { $0.chatId == data.chatId }) {
                currentPath.popTo(existingChat)
                if let messageId = data.messageId {
                    if isSwitchingSpace {
                        // Chat is being created fresh — include messageId in path data
                        currentPath.replaceLast(data)
                    } else {
                        // Chat already on screen — scroll via provider without recreating
                        chatProvider.scrollToMessage(chatId: data.chatId, messageId: messageId)
                    }
                }
            } else {
                currentPath.openOnce(data)
            }
        case .spaceChat(let data):
            // Homepage refactor may place ChatCoordinatorData (not SpaceChatCoordinatorData)
            // as home screen. Check for existing ChatCoordinatorData for the same space.
            if let existingChat = currentPath.path.lazy.compactMap({ $0.base as? ChatCoordinatorData }).first(where: { $0.spaceId == data.spaceId }) {
                currentPath.popTo(existingChat)
            } else {
                currentPath.openOnce(data)
            }
        case .widget(let data):
            currentPath.openOnce(data)
        case .discussion(let data):
            currentPath.openOnce(data)
        }
        
        if navigationPath != currentPath {
            navigationPath = currentPath
        }
    }
    
    // Checks is object supported for opening
    private func checkIsDataSupportedForOpening(_ data: ScreenData) async throws -> Bool {
        if FeatureFlags.fixAvatarTapFreeze, case .alert(.spaceMember) = data { return true }
        guard let objectId = data.objectId else { return true }
        
        let document = documentsProvider.document(objectId: objectId, spaceId: data.spaceId, mode: .preview)
        try await document.open()
        guard let details = document.details else { return false }
        
        if !details.isSupportedForOpening {
            toastBarData = ToastBarData(Loc.openTypeError(details.objectType.displayName), type: .neutral)
        }
            
        return details.isSupportedForOpening
    }
    
    private func showAlert(_ data: AlertScreenData) async {
        await dismissAllPresented?()

        switch data {
        case .spaceMember(let objectInfo):
            profileData = objectInfo
        case .chatCreate(let chatData):
            chatCreateData = chatData
        case .bookmarkCreate(let bookmarkData):
            bookmarkCreateData = bookmarkData
        case .widgets(let widgetData):
            overlayWidgetsData = widgetData
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
    
    private func setActiveSpace(spaceId: String) {
        guard currentSpaceId != spaceId else { return }
        currentSpaceId = spaceId
        // Preload space in middleware for faster loading. SpaceLoadingContainerView will also call this.
        Task { try await activeSpaceManager.setActiveSpace(spaceId: spaceId) }
    }
    
    private func handleActiveSpace(info: AccountInfo?) async {
        guard info?.accountSpaceId != currentSpaceId else { return }

        if let info {
            await showSpace(spaceId: info.accountSpaceId)
        } else {
            await dismissAllPresented?()
            navigationPath.popToRoot()
        }
    }

    // MARK: - App Actions
    private func handleAppAction(action: AppAction) async throws {
        keyboardDismiss?()
        await dismissAllPresented?()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            await createAndShowNewObject(typeId: typeId, route: .homeScreen)
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
        case let .chatMessage(chatObjectId, spaceId, messageId):
            await handleChatMessageDeepLink(chatObjectId: chatObjectId, spaceId: spaceId, messageId: messageId)
        case .membership(let tierId):
            guard accountManager.account.allowMembership else { return }
            membershipTierId = tierId.identifiable
        case .networkConfig:
            toastBarData = ToastBarData(Loc.unsupportedDeeplink)
        case let .hi(identity, key):
            await handleHiDeepLink(identity: identity, key: key)
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

    private func handleChatMessageDeepLink(chatObjectId: String, spaceId: String, messageId: String) async {
        let document = documentsProvider.document(objectId: chatObjectId, spaceId: spaceId, mode: .preview)
        do {
            try await document.open()
            guard let details = document.details else {
                showObjectIsNotAvailableAlert = true
                return
            }

            if details.editorViewType == .chat {
                let chatId = details.resolvedLayoutValue == .chatDerived ? details.id : details.chatId
                let data = ChatCoordinatorData(chatId: chatId, spaceId: spaceId, messageId: messageId)
                try? await showScreen(data: .chat(data))
            } else if details.editorViewType == .discussion || details.discussionId.isNotEmpty {
                // Standalone discussion objects use their own id; objects with a discussion property use discussionId
                let discussionId = details.editorViewType == .discussion ? details.id : details.discussionId
                var currentPath: HomePath
                let isSwitchingSpace: Bool
                if let spacePath = await prepareSpacePath(spaceId: spaceId) {
                    currentPath = spacePath
                    isSwitchingSpace = true
                } else {
                    currentPath = navigationPath
                    isSwitchingSpace = false
                }

                // Check if discussion is already in the navigation path (same pattern as .chat in showScreen)
                if let existingDiscussion = currentPath.path.lazy.compactMap({ $0.base as? DiscussionCoordinatorData }).first(where: { $0.discussionId == discussionId }) {
                    await dismissAllPresented?()
                    currentPath.popTo(existingDiscussion)
                    if isSwitchingSpace {
                        currentPath.replaceLast(DiscussionCoordinatorData(
                            discussionId: discussionId,
                            objectId: details.id,
                            objectName: details.name,
                            spaceId: spaceId,
                            messageId: messageId
                        ))
                    } else {
                        chatProvider.scrollToMessage(chatId: discussionId, messageId: messageId)
                    }
                } else {
                    await dismissAllPresented?()

                    // Standalone discussion objects (layout == .discussion) don't need an editor screen
                    if details.editorViewType == .discussion {
                        let discussionData = DiscussionCoordinatorData(
                            discussionId: discussionId,
                            objectId: details.id,
                            objectName: details.name,
                            spaceId: spaceId,
                            messageId: messageId
                        )
                        currentPath.push(discussionData)
                    } else {
                        guard let editorScreenData = ScreenData(details: details).editorScreenData else {
                            showObjectIsNotAvailableAlert = true
                            navigationPath = currentPath
                            return
                        }
                        currentPath.openOnce(editorScreenData)

                        let discussionData = DiscussionCoordinatorData(
                            discussionId: discussionId,
                            objectId: details.id,
                            objectName: details.name,
                            spaceId: spaceId,
                            messageId: messageId
                        )
                        currentPath.push(discussionData)
                    }
                }

                navigationPath = currentPath
            } else {
                showObjectIsNotAvailableAlert = true
            }
        } catch {
            showObjectIsNotAvailableAlert = true
        }
    }

    private func handleHiDeepLink(identity: String, key: String) async {
        guard identity.isNotEmpty else { return }

        if let existingSpace = workspaceStorage.oneToOneSpaceView(identity: identity) {
            try? await showScreen(data: .spaceChat(SpaceChatCoordinatorData(spaceId: existingSpace.targetSpaceId)))
            return
        }

        if let newSpaceId = try? await workspaceService.createOneToOneSpace(oneToOneIdentity: identity, metadataKey: key) {
            try? await showScreen(data: .spaceChat(SpaceChatCoordinatorData(spaceId: newSpaceId)))
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
        if type.isChatType {
            let screenData = ScreenData.alert(.chatCreate(ChatCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .quickAction
            )))
            showScreenSync(data: screenData)
            return
        }

        if type.isBookmarkType {
            let screenData = ScreenData.alert(.bookmarkCreate(BookmarkCreateScreenData(
                spaceId: type.spaceId,
                analyticsRoute: .quickAction
            )))
            showScreenSync(data: screenData)
            return
        }

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

    func onShowWidgetsOverlay(spaceId: String) {
        overlayWidgetsData = HomeWidgetData(spaceId: spaceId)
    }

    func popToFirstInSpace() {
        guard !pathChanging else { return }
        navigationPath.popToFirstOpened()
    }
}
