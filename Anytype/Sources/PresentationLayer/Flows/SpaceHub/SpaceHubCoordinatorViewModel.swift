import SwiftUI
import DeepLinks
import Services
import Combine


@MainActor
final class SpaceHubCoordinatorViewModel: ObservableObject {
    @Published var showSpaceManager = false
    @Published var showSpaceShareTip = false
    @Published var typeSearchForObjectCreationSpaceId: StringIdentifiable?
    @Published var sharingSpaceId: StringIdentifiable?
    @Published var showSpaceSwitchData: SpaceSwitchModuleData?
    @Published var membershipTierId: IntIdentifiable?
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var spaceJoinData: SpaceJoinModuleData?
    @Published var membershipNameFinalizationData: MembershipTier?
    @Published var showGlobalSearchData: GlobalSearchModuleData?
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettingsData: AccountInfo?
    @Published var toastBarData = ToastBarData.empty
    
    @Published var spaceInfo: AccountInfo?
    private var currentSpaceId: String? { spaceInfo?.accountSpaceId }
    
    @Published var pathChanging: Bool = false
    @Published var editorPath = HomePath() {
        didSet { }//updateLastOpenedScreen() }
    }
    var pageNavigation: PageNavigation {
        PageNavigation(
            push: { [weak self] data in
                self?.pushSync(data: data)
            }, pop: { [weak self] in
                self?.editorPath.pop()
            }, replace: { [weak self] data in
                self?.editorPath.replaceLast(data)
            }
        )
    }
    private var paths = [String: HomePath]()

    var keyboardDismiss: (() -> ())?
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
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.workspaceStorage)
    private var workspacesStorage: any WorkspacesStorageProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    
    private var membershipStatusSubscription: AnyCancellable?
    
    init() {
        startSubscriptions()
    }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    // MARK: - Setup
    func setup() async {
        await spaceSetupManager.registerSpaceSetter(sceneId: sceneId, setter: activeSpaceManager)
    }
    
    func startHandleAppActions() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    func startHandleWorkspaceInfo() async {
        await activeSpaceManager.setupActiveSpace()
        for await info in activeSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }

    // MARK: - Private
    
    private func startSubscriptions() {
        membershipStatusSubscription = Container.shared
            .membershipStatusStorage.resolve()
            .statusPublisher.receiveOnMain()
            .sink { [weak self] membership in
                guard membership.status == .pendingRequiresFinalization else { return }
                
                self?.membershipNameFinalizationData = membership.tier
            }
    }

    func typeSearchForObjectCreationModule(spaceId: String) -> TypeSearchForNewObjectCoordinatorView {
        TypeSearchForNewObjectCoordinatorView(spaceId: spaceId) { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - Navigation
    private func openObject(screenData: EditorScreenData) {
        pushSync(data: screenData)
    }
    
    private func pushSync(data: EditorScreenData) {
        Task { try await push(data: data) }
    }
    
    private func push(data: EditorScreenData) async throws {
        guard let currentSpaceId else { return } // TODO: Support push with no spaces
        
        guard let objectId = data.objectId else {
            editorPath.push(data)
            return
        }
        let document = documentsProvider.document(objectId: objectId, mode: .preview)
        try await document.open()
        guard let details = document.details else {
            return
        }
        guard details.isSupportedForEdit else {
            toastBarData = ToastBarData(text: Loc.openTypeError(details.objectType.name), showSnackBar: true, messageType: .none)
            return
        }
        let spaceId = document.spaceId
        if currentSpaceId != spaceId {
            // Check space Is deleted
            guard workspacesStorage.spaceView(spaceId: spaceId).isNotNil else { return }
            
            paths[currentSpaceId] = editorPath
           
            try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
            
            var path = paths[spaceId] ?? HomePath()
            if path.count == 0 {
                path.push(spaceInfo)
            }
            
            path.push(data)
            editorPath = path
        } else {
            editorPath.push(data)
        }
    }
    
    private func switchSpace(info: AccountInfo?) {
        Task {
            guard let info else {
                editorPath.popToRoot()
                return
            }
            
            guard currentSpaceId != info.accountSpaceId else { return }
            
            var newPath = HomePath()
            newPath.push(info)
            editorPath = newPath
            self.spaceInfo = info
            
            
//            // Backup current
//            if let currentSpaceId = currentSpaceId {
//                paths[currentSpaceId] = editorPath
//            }
//            // Restore New
//            var path = paths[info.accountSpaceId] ?? HomePath()
//            if path.count == 0 {
//                path.push(info)
//            }
            
//            if currentSpaceId.isNotNil {
//                await dismissAllPresented?()
//            }
            
//            do {
//                if let screen = try await getLastOpenedScreen(newInfo: info) {
//                    path.push(screen)
//                }
//            }
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
    
    private func createAndShowNewObject(
            typeId: String,
            route: AnalyticsEventsRouteKind
        ) {
            // TODO: Product decision
        }
        
    private func handleDeepLink(deepLink: DeepLink) async throws {
        switch deepLink {
        case .createObjectFromWidget:
            // TODO: Product decision
            break
        case .showSharingExtension:
            // TODO: Product decision
            // sharingSpaceId = ???
            break
        case .spaceSelection:
            showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: spaceInfo?.accountSpaceId, sceneId: sceneId)
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, sceneId: sceneId)
        case .object(let objectId, let spaceId):
            // TODO: Open space and show object
            break
//                let document = documentsProvider.document(objectId: objectId, mode: .preview)
//                try await document.open()
//                guard let editorData = document.details?.editorScreenData() else { return }
//                try await push(data: editorData)
        case .spaceShareTip:
            showSpaceShareTip = true
        case .membership(let tierId):
            guard accountManager.account.isInProdNetwork else { return }
            membershipTierId = tierId.identifiable
        }
    }

}

extension SpaceHubCoordinatorViewModel: HomeWidgetsModuleOutput {
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
        
    func onObjectSelected(screenData: EditorScreenData) {
        openObject(screenData: screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: spaceInfo.widgetsId,
            spaceId: spaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeSourceData = nil
            }
        )
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: spaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onSpaceSelected() {
        showSpaceSettingsData = spaceInfo
    }
    
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
}

extension SpaceHubCoordinatorViewModel: SetObjectCreationCoordinatorOutput {   
    func showEditorScreen(data: EditorScreenData) {
        pushSync(data: data)
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
    
    func onCreateObjectSelected(screenData: EditorScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: spaceInfo?.accountSpaceId, sceneId: sceneId)
    }

    func onHomeSelected() {
        guard !pathChanging else { return }
        editorPath.popToRoot()
    }

    func onForwardSelected() {
        guard !pathChanging else { return }
        editorPath.pushFromHistory()
    }

    func onBackwardSelected() {
        guard !pathChanging else { return }
        editorPath.pop()
    }
    
    func onPickTypeForNewObjectSelected() {
        guard let spaceInfo else { return }
        
        UISelectionFeedbackGenerator().selectionChanged()
        typeSearchForObjectCreationSpaceId = spaceInfo.accountSpaceId.identifiable
    }
    
    func onSpaceHubSelected() {
        UISelectionFeedbackGenerator().selectionChanged()
        editorPath.popToRoot()
    }
}
