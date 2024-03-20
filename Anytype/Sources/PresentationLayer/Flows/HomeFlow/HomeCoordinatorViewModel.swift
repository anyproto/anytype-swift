import Foundation
import SwiftUI
import Combine
import Services
import AnytypeCore
import DeepLinks

@MainActor
final class HomeCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomPanelModuleOutput, HomeBottomNavigationPanelModuleOutput,
                                             SetObjectCreationCoordinatorOutput {
    
    // MARK: - DI
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let navigationContext: NavigationContextProtocol
    private let createWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let blockService: BlockServiceProtocol
    private let pasteboardBlockService: PasteboardBlockServiceProtocol
    private let typeProvider: ObjectTypeProviderProtocol
    private let appActionsStorage: AppActionStorage
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    private let spaceSwitchCoordinatorAssembly: SpaceSwitchCoordinatorAssemblyProtocol
    private let spaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol
    private let shareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol
    private let editorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol
    private let homeBottomNavigationPanelModuleAssembly: HomeBottomNavigationPanelModuleAssemblyProtocol
    private let objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol
    private let workspacesStorage: WorkspacesStorageProtocol
    private let documentsProvider: DocumentsProviderProtocol
    private let setObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol
    private let sharingTipCoordinator: SharingTipCoordinatorProtocol
    private let notificationCoordinator: NotificationCoordinatorProtocol
    private let typeSearchCoordinatorAssembly: TypeSearchForNewObjectCoordinatorAssemblyProtocol
    
    // MARK: - State
    
    private var viewLoaded = false
    private var subscriptions = [AnyCancellable]()
    private var paths = [String: HomePath]()
    private var setObjectCreationCoordinator: SetObjectCreationCoordinatorProtocol?
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeModuleChangeModel?
    @Published var showSearchData: SearchModuleModel?
    @Published var showSpaceSwitch: Bool = false
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettings: Bool = false
    @Published var showSharing: Bool = false
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var editorPath = HomePath() {
        didSet { UserDefaultsConfig.lastOpenedPage = editorPath.lastPathElement as? EditorScreenData }
    }
    @Published var showTypeSearchForObjectCreation: Bool = false
    @Published var toastBarData = ToastBarData.empty
    @Published var pathChanging: Bool = false
    @Published var keyboardToggle: Bool = false
    @Published var spaceJoinData: SpaceJoinModuleData?
    
    private var currentSpaceId: String?
    
    var pageNavigation: PageNavigation {
        PageNavigation(
            push: { [weak self] data in
                self?.push(data: data)
            }, pop: { [weak self] in
                self?.editorPath.pop()
            }, replace: { [weak self] data in
                self?.editorPath.replaceLast(data)
            }
        )
    }

    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        navigationContext: NavigationContextProtocol,
        createWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        blockService: BlockServiceProtocol,
        pasteboardBlockService: PasteboardBlockServiceProtocol,
        typeProvider: ObjectTypeProviderProtocol,
        appActionsStorage: AppActionStorage,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol,
        spaceSwitchCoordinatorAssembly: SpaceSwitchCoordinatorAssemblyProtocol,
        spaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol,
        shareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol,
        editorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol,
        homeBottomNavigationPanelModuleAssembly: HomeBottomNavigationPanelModuleAssemblyProtocol,
        objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol,
        workspacesStorage: WorkspacesStorageProtocol,
        documentsProvider: DocumentsProviderProtocol,
        setObjectCreationCoordinatorAssembly: SetObjectCreationCoordinatorAssemblyProtocol,
        sharingTipCoordinator: SharingTipCoordinatorProtocol,
        notificationCoordinator: NotificationCoordinatorProtocol,
        typeSearchCoordinatorAssembly: TypeSearchForNewObjectCoordinatorAssemblyProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.navigationContext = navigationContext
        self.createWidgetCoordinatorAssembly = createWidgetCoordinatorAssembly
        self.searchModuleAssembly = searchModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.objectActionsService = objectActionsService
        self.defaultObjectService = defaultObjectService
        self.blockService = blockService
        self.pasteboardBlockService = pasteboardBlockService
        self.typeProvider = typeProvider
        self.appActionsStorage = appActionsStorage
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
        self.spaceSwitchCoordinatorAssembly = spaceSwitchCoordinatorAssembly
        self.spaceSettingsCoordinatorAssembly = spaceSettingsCoordinatorAssembly
        self.shareCoordinatorAssembly = shareCoordinatorAssembly
        self.editorCoordinatorAssembly = editorCoordinatorAssembly
        self.homeBottomNavigationPanelModuleAssembly = homeBottomNavigationPanelModuleAssembly
        self.objectTypeSearchModuleAssembly = objectTypeSearchModuleAssembly
        self.workspacesStorage = workspacesStorage
        self.documentsProvider = documentsProvider
        self.setObjectCreationCoordinatorAssembly = setObjectCreationCoordinatorAssembly
        self.sharingTipCoordinator = sharingTipCoordinator
        self.notificationCoordinator = notificationCoordinator
        self.typeSearchCoordinatorAssembly = typeSearchCoordinatorAssembly
    }

    func onAppear() {
        guard !viewLoaded else { return }
        viewLoaded = true
        
        Task {
            await notificationCoordinator.startHandle()
        }
        
        activeWorkspaceStorage
            .workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] newInfo in
                self?.switchSpace(info: newInfo)
            }
            .store(in: &subscriptions)
        
        appActionsStorage.$action
            .compactMap { $0 }
            .receiveOnMain()
            .sink { [weak self] action in
                self?.handleAppAction(action: action)
                self?.appActionsStorage.action = nil
            }
            .store(in: &subscriptions)
        
        sharingTipCoordinator.startObservingTips()
    }
    
    func homeWidgetsModule(info: AccountInfo) -> AnyView? {
        return homeWidgetsModuleAssembly.make(info: info, output: self, widgetOutput: self, bottomPanelOutput: self)
    }
    
    func homeBottomNavigationPanelModule() -> AnyView {
        return homeBottomNavigationPanelModuleAssembly.make(homePath: editorPath, output: self)
    }

    func changeSourceModule(data: WidgetChangeSourceSearchModuleModel) -> AnyView {
        return newSearchModuleAssembly.widgetChangeSourceSearchModule(data: data)
    }
    
    func changeTypeModule(data: WidgetTypeModuleChangeModel) -> AnyView {
        return widgetTypeModuleAssembly.makeChangeType(data: data)
    }
    
    func searchModule(data: SearchModuleModel) -> AnyView {
        return searchModuleAssembly.makeObjectSearch(data: data)
    }
    
    func createWidgetModule(data: CreateWidgetCoordinatorModel) -> AnyView {
        return createWidgetCoordinatorAssembly.make(data: data)
    }
    
    func createSpaceSwitchModule() -> AnyView {
        return spaceSwitchCoordinatorAssembly.make()
    }
    
    func createSpaceSeetingsModule() -> AnyView {
        return spaceSettingsCoordinatorAssembly.make()
    }

    func createSharingModule() -> AnyView {
        return shareCoordinatorAssembly.make()
    }

    func editorModule(data: EditorScreenData) -> AnyView {
        return editorCoordinatorAssembly.make(data: data)
    }

    func typeSearchForObjectCreationModule() -> AnyView {
        typeSearchCoordinatorAssembly.make { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - HomeWidgetsModuleOutput
    
    // MARK: - CommonWidgetModuleOutput
        
    func onObjectSelected(screenData: EditorScreenData) {
        openObject(screenData: screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeSourceData = nil
            }
        )
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        showChangeTypeData = WidgetTypeModuleChangeModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onSpaceSelected() {
        showSpaceSettings.toggle()
    }
    
    func onCreateObjectInSetDocument(setDocument: SetDocumentProtocol) {
        setObjectCreationCoordinator = setObjectCreationCoordinatorAssembly.make()
        setObjectCreationCoordinator?.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
    // MARK: - HomeBottomNavigationPanelModuleOutput
    
    func onSearchSelected() {
        AnytypeAnalytics.instance().logScreenSearch()
        showSearchData = SearchModuleModel(
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            title: nil,
            onSelect: { [weak self] data in
                AnytypeAnalytics.instance().logSearchResult()
                self?.showSearchData = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.openObject(screenData: data.editorScreenData)
                }
            }
        )
    }
    
    func onCreateObjectSelected(screenData: EditorScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        showSpaceSwitch.toggle()
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
        UISelectionFeedbackGenerator().selectionChanged()
        showTypeSearchForObjectCreation.toggle()
    }

    // MARK: - SetObjectCreationCoordinatorOutput
    
    func showEditorScreen(data: EditorScreenData) {
        push(data: data)
    }
    
    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        push(data: screenData)
    }
    
    private func createAndShowDefaultObject(route: AnalyticsEventsRouteKind) {
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: route)
            openObject(screenData: details.editorScreenData())
        }
    }
    
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
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: route)
            
            openObject(screenData: details.editorScreenData())
        }
    }
    
    private func handleAppAction(action: AppAction) {
        keyboardToggle.toggle()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .deepLink(let deepLink):
            handleDeepLink(deepLink: deepLink)
        }
    }
    
    private func handleDeepLink(deepLink: DeepLink) {
        switch deepLink {
        case .createObjectFromWidget:
            createAndShowDefaultObject(route: .widget)
        case .showSharingExtension:
            navigationContext.dismissAllPresented(animated: true) { [weak self] in
                self?.showSharing = true
            }
        case .spaceSelection:
            navigationContext.dismissAllPresented(animated: true) { [weak self] in
                self?.showSpaceSwitch = true
            }
        case let .galleryImport(type, source):
            navigationContext.dismissAllPresented(animated: true) { [weak self] in
                self?.showGalleryImport = GalleryInstallationData(type: type, source: source)
            }
        case .invite(let cid, let key):
            if FeatureFlags.multiplayer {
                navigationContext.dismissAllPresented(animated: true) { [weak self] in
                    self?.spaceJoinData = SpaceJoinModuleData(cid: cid, key: key)
                }
            }
        }
    }
    
    private func push(data: EditorScreenData) {
        Task {
            guard let objectId = data.objectId else {
                editorPath.push(data)
                return
            }
            let document = documentsProvider.document(objectId: objectId, forPreview: true)
            try await document.openForPreview()
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
                
                if let currentSpaceId = currentSpaceId {
                    paths[currentSpaceId] = editorPath
                }
               
                currentSpaceId = spaceId
                try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
                
                var path = paths[spaceId] ?? HomePath()
                if path.count == 0 {
                    path.push(activeWorkspaceStorage.workspaceInfo)
                }
                
                path.push(data)
                editorPath = path
            } else {
                editorPath.push(data)
            }
        }
    }
    
    private func switchSpace(info newInfo: AccountInfo) {
        Task {
            guard currentSpaceId != newInfo.accountSpaceId else { return }
            // Backup current
            if let currentSpaceId = currentSpaceId {
                paths[currentSpaceId] = editorPath
            }
            // Restore New
            var path = paths[newInfo.accountSpaceId] ?? HomePath()
            if path.count == 0 {
                path.push(newInfo)
            }
            
            do {
                // Restore last open page
                if currentSpaceId.isNil, let lastOpenPage = UserDefaultsConfig.lastOpenedPage {
                    if let objectId = lastOpenPage.objectId {
                        let document = documentsProvider.document(objectId: objectId, forPreview: true)
                        try await document.openForPreview()
                        // Check space is deleted or switched
                        if document.spaceId == newInfo.accountSpaceId {
                            path.push(lastOpenPage)
                        }
                    } else {
                        path.push(lastOpenPage)
                    }
                }
            }
            
            currentSpaceId = newInfo.accountSpaceId
            editorPath = path
            
        }
    }
}
