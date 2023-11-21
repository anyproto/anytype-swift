import Foundation
import SwiftUI
import Combine
import Services
import AnytypeCore

@MainActor
final class HomeWidgetsCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomPanelModuleOutput, HomeBottomNavigationPanelModuleOutput {
    
    // MARK: - DI
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let navigationContext: NavigationContextProtocol
    private let createWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let dashboardService: DashboardServiceProtocol
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
    
    
    // MARK: - State
    
    private var viewLoaded = false
    private var subscriptions = [AnyCancellable]()
    private var paths = [String: HomePath]()
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeModuleChangeModel?
    @Published var showSearchData: SearchModuleModel?
    @Published var showSpaceSwitch: Bool = false
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettings: Bool = false
    @Published var showSharing: Bool = false
    @Published var editorPath = HomePath() {
        didSet { UserDefaultsConfig.lastOpenedPage = editorPath.lastPathElement as? EditorScreenData }
    }
    @Published var showCreateObjectWithType: Bool = false
    @Published var toastBarData = ToastBarData.empty
    
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
        dashboardService: DashboardServiceProtocol,
        appActionsStorage: AppActionStorage,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol,
        spaceSwitchCoordinatorAssembly: SpaceSwitchCoordinatorAssemblyProtocol,
        spaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol,
        shareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol,
        editorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol,
        homeBottomNavigationPanelModuleAssembly: HomeBottomNavigationPanelModuleAssemblyProtocol,
        objectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol,
        workspacesStorage: WorkspacesStorageProtocol,
        documentsProvider: DocumentsProviderProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.navigationContext = navigationContext
        self.createWidgetCoordinatorAssembly = createWidgetCoordinatorAssembly
        self.searchModuleAssembly = searchModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.dashboardService = dashboardService
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
    }

    func onAppear() {
        guard !viewLoaded else { return }
        viewLoaded = true
        
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

    func createObjectWithTypeModule() -> AnyView {
        AnytypeAnalytics.instance().logOnboardingTooltip(tooltip: .selectType)
        return objectTypeSearchModuleAssembly.objectTypeSearchForCreateObject(
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId
        ) { [weak self] type in
            AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType, route: .longTap)
            self?.showCreateObjectWithType = false
            self?.createAndShowNewPage(type: type)
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
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        showSpaceSwitch.toggle()
    }

    func onHomeSelected() {
        editorPath.popToRoot()
    }

    func onForwardSelected() {
        editorPath.pushFromHistory()
    }

    func onBackwardSelected() {
        editorPath.pop()
    }
    
    func onCreateObjectWithTypeSelected() {
        showCreateObjectWithType.toggle()
    }

    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        push(data: screenData)
    }
    
    private func createAndShowNewPage() {
        Task {
            let details = try await dashboardService.createNewPage(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            openObject(screenData: details.editorScreenData())
        }
    }

    private func createAndShowNewPage(type: ObjectType) {
        Task {
            let details = try await dashboardService.createNewPage(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                typeUniqueKey: type.uniqueKey,
                templateId: type.defaultTemplateId
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            openObject(screenData: details.editorScreenData())
        }
    }
    
    private func handleAppAction(action: AppAction) {
        switch action {
        case .createObject:
            createAndShowNewPage()
        case .showSharingExtension:
            showSharing = true
        case .spaceSelection:
            navigationContext.dismissAllPresented(animated: true, completion: { [weak self] in
                self?.editorPath.popToRoot()
                self?.showSpaceSwitch = true
            })
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
            
            currentSpaceId = newInfo.accountSpaceId
            editorPath = path
            
        }
    }
}
