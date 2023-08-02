import Foundation
import SwiftUI
import Combine

@MainActor
final class HomeWidgetsCoordinatorViewModel: ObservableObject,
                                             HomeWidgetsModuleOutput, CommonWidgetModuleOutput,
                                             HomeBottomPanelModuleOutput {
    
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
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let quickActionsStorage: QuickActionsStorage
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    
    // MARK: - State
    
    private var viewLoaded = false
    private var subscriptions = [AnyCancellable]()
    
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeModuleChangeModel?
    @Published var showSearchData: SearchModuleModel?
    @Published var createWidgetData: CreateWidgetCoordinatorModel?
    
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
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        quickActionsStorage: QuickActionsStorage,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
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
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.quickActionsStorage = quickActionsStorage
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
    }

    func onAppear() {
        guard !viewLoaded else { return }
        viewLoaded = true
        quickActionsStorage.$action
            .receiveOnMain()
            .sink { [weak self] action in
            switch action {
            case .newNote:
                self?.createAndShowNewPage()
                self?.quickActionsStorage.action = nil
            case .none:
                break
            }
        }
        .store(in: &subscriptions)
        
        if let data = UserDefaultsConfig.lastOpenedPage {
            UserDefaultsConfig.lastOpenedPage = nil
            openObject(screenData: data)
            return
        }
        
        if UserDefaultsConfig.showKeychainAlert {
            UserDefaultsConfig.showKeychainAlert = false
            let module = dashboardAlertsAssembly.makeKeychainRemind(context: .signup)
            navigationContext.present(module)
        }
    }
    
    func homeWidgetsModule() -> AnyView {
        return homeWidgetsModuleAssembly.make(output: self, widgetOutput: self, bottomPanelOutput: self)
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
        createWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    // MARK: - HomeBottomPanelModuleOutput
    
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        createWidgetData = CreateWidgetCoordinatorModel(
            widgetObjectId: activeWorkspaceStorage.workspaceInfo.widgetsId,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
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
    
    // MARK: - Private
    
    private func openObject(screenData: EditorScreenData) {
        editorBrowserCoordinator.startFlow(data: screenData)
    }
    
    private func createAndShowNewPage() {
        Task {
            guard let details = try? await dashboardService.createNewPage(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) else { return }
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, route: .navigation, view: .home)
            openObject(screenData: details.editorScreenData())
        }
    }
}
