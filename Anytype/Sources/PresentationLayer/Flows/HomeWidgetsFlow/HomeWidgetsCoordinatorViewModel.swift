import Foundation
import SwiftUI
import Combine
import Services
import AnytypeCore
import NavigationBackport

@MainActor
final class HomeWidgetsCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomPanelModuleOutput, SpaceSwitchModuleOutput {
    
    // MARK: - DI
    
    private let homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let navigationContext: NavigationContextProtocol
    private let createWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol
    private let editorBrowserCoordinator: EditorBrowserCoordinatorProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let settingsCoordinator: SettingsCoordinatorProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let dashboardService: DashboardServiceProtocol
    private let appActionsStorage: AppActionStorage
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    private let spaceSwitchModuleAssembly: SpaceSwitchModuleAssemblyProtocol
    private let spaceCreateModuleAssembly: SpaceCreateModuleAssemblyProtocol
    private let spaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol
    private let shareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol
    private let editorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol
    
    // MARK: - State
    
    private var viewLoaded = false
    private var subscriptions = [AnyCancellable]()
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeModuleChangeModel?
    @Published var showSearchData: SearchModuleModel?
    @Published var showSpaceSwitch: Bool = false
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettings: Bool = false
    @Published var showSpaceCreate: Bool = false
    @Published var showSharing: Bool = false
//    @Published var editor: EditorScreenData?
    @Published var editorPath = NBNavigationPath()
    
    @Published var info: AccountInfo? {
        didSet {
            // Prevent animation for first sync
            if oldValue.isNotNil {
                homeAnimationId = UUID()
            }
        }
    }
    @Published var homeAnimationId = UUID()
    
    init(
        homeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        navigationContext: NavigationContextProtocol,
        createWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol,
        editorBrowserCoordinator: EditorBrowserCoordinatorProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        settingsCoordinator: SettingsCoordinatorProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        dashboardService: DashboardServiceProtocol,
        appActionsStorage: AppActionStorage,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol,
        spaceSwitchModuleAssembly: SpaceSwitchModuleAssemblyProtocol,
        spaceCreateModuleAssembly: SpaceCreateModuleAssemblyProtocol,
        spaceSettingsCoordinatorAssembly: SpaceSettingsCoordinatorAssemblyProtocol,
        shareCoordinatorAssembly: ShareCoordinatorAssemblyProtocol,
        editorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol
    ) {
        self.homeWidgetsModuleAssembly = homeWidgetsModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.navigationContext = navigationContext
        self.createWidgetCoordinatorAssembly = createWidgetCoordinatorAssembly
        self.editorBrowserCoordinator = editorBrowserCoordinator
        self.searchModuleAssembly = searchModuleAssembly
        self.settingsCoordinator = settingsCoordinator
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.dashboardService = dashboardService
        self.appActionsStorage = appActionsStorage
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
        self.spaceSwitchModuleAssembly = spaceSwitchModuleAssembly
        self.spaceCreateModuleAssembly = spaceCreateModuleAssembly
        self.spaceSettingsCoordinatorAssembly = spaceSettingsCoordinatorAssembly
        self.shareCoordinatorAssembly = shareCoordinatorAssembly
        self.editorCoordinatorAssembly = editorCoordinatorAssembly
    }

    func onAppear() {
        guard !viewLoaded else { return }
        viewLoaded = true
        
        activeWorkspaceStorage
            .workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] info in
                self?.info = info
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
        
        if let data = UserDefaultsConfig.lastOpenedPage {
            UserDefaultsConfig.lastOpenedPage = nil
            openObject(screenData: data)
            return
        }
    }
    
    func homeWidgetsModule() -> AnyView? {
        guard let info else { return nil }
        return homeWidgetsModuleAssembly.make(info: info, output: self, widgetOutput: self, bottomPanelOutput: self)
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
        return spaceSwitchModuleAssembly.make(output: self)
    }
    
    func createSpaceSeetingsModule() -> AnyView {
        return spaceSettingsCoordinatorAssembly.make()
    }
    
    func createSpaceCreateModule() -> AnyView {
        return spaceCreateModuleAssembly.make()
    }
    
    func createSharingModule() -> AnyView {
        return shareCoordinatorAssembly.make()
    }
    
    func editorModule(data: EditorScreenData) -> AnyView {
        return editorCoordinatorAssembly.make(data: data)
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
        if FeatureFlags.multiSpaceSettings {
            showSpaceSettings.toggle()
        } else {
            settingsCoordinator.startFlow()
        }
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
    
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
    
    func onSettingsSelected() {
        settingsCoordinator.startFlow()
    }
    
    func onProfileSelected() {
        showSpaceSwitch.toggle()
    }
    
    // MARK: - SpaceSwitchModuleOutput
    
    func onCreateSpaceSelected() {
        showSpaceCreate.toggle()
    }
    
    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        editorPath.push(screenData)
//        editor = screenData
//        editorBrowserCoordinator.startFlow(data: screenData)
    }
    
    private func createAndShowNewPage() {
//        editor = .bin
//        editorPath.push(screenData)
        Task {
            guard let details = try? await dashboardService.createNewPage(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            openObject(screenData: details.editorScreenData())
        }
    }
    
    private func handleAppAction(action: AppAction) {
        switch action {
        case .createObject:
            createAndShowNewPage()
        case .showSharingExtension:
            showSharing.toggle()
        }
    }
}
