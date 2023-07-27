import Foundation
import AnytypeCore
import Services
import Combine

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    // MARK: - DI
    
    private var widgetObject: BaseDocumentProtocol?
    private let registry: HomeWidgetsRegistryProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private let objectActionService: ObjectActionsServiceProtocol
    private let recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol
    private let documentService: DocumentServiceProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    // Temporary
    private let workspaceService: WorkspaceServiceProtocol
    private let workspacesStorage: WorkspacesStorageProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    // MARK: - State
    
    @Published var models: [HomeWidgetSubmoduleModel] = []
    @Published var bottomPanelProvider: HomeSubmoduleProviderProtocol
    @Published var hideEditButton: Bool = false
    @Published var dataLoaded: Bool = false
    // Temporary
    @Published var showWorkspacesSwitchList: Bool = false
    @Published var showWorkspacesDeleteList: Bool = false
    @Published var workspaces: [ObjectDetails] = []
    private var activeSpaceSubscription: AnyCancellable?
    private var objectSubscriptions = [AnyCancellable]()
    
    init(
        registry: HomeWidgetsRegistryProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        bottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        objectActionService: ObjectActionsServiceProtocol,
        recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol,
        documentService: DocumentServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        workspaceService: WorkspaceServiceProtocol,
        workspacesStorage: WorkspacesStorageProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.registry = registry
        self.blockWidgetService = blockWidgetService
        self.bottomPanelProvider = bottomPanelProviderAssembly.make(stateManager: stateManager)
        self.stateManager = stateManager
        self.objectActionService = objectActionService
        self.recentStateManagerProtocol = recentStateManagerProtocol
        self.documentService = documentService
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.workspaceService = workspaceService
        self.workspacesStorage = workspacesStorage
        self.output = output
        setupSpaceSubscription()
    }
    
    func onAppear() {}
    
    func onDisappear() {}
    
    func onEditButtonTap() {
        AnytypeAnalytics.instance().logEditWidget()
        stateManager.setEditState(true)
    }
    
    func dropUpdate(from: DropDataElement<HomeWidgetSubmoduleModel>, to: DropDataElement<HomeWidgetSubmoduleModel>) {
        models.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func dropFinish(from: DropDataElement<HomeWidgetSubmoduleModel>, to: DropDataElement<HomeWidgetSubmoduleModel>) {
        guard let widgetObject else { return }
        if let info = widgetObject.widgetInfo(blockId: from.data.blockId) {
            AnytypeAnalytics.instance().logReorderWidget(source: info.source.analyticsSource)
        }
        Task {
            try? await objectActionService.move(
                dashboadId: widgetObject.objectId,
                blockId: from.data.blockId,
                dropPositionblockId: to.data.blockId,
                position: to.index > from.index ? .bottom : .top
            )
        }
    }
    
    // Temporary
    func onCreateSpaceTap() {
        Task {
            _ = try await workspaceService.createWorkspace(name: "Workspace \(workspacesStorage.workspaces.count + 1)")
        }
    }
    
    // Temporary
    func onDeleteSpaceTap() {
        workspaces = workspacesStorage.workspaces
        showWorkspacesDeleteList = true
    }
    
    // Temporary
    func onSwitchSapceTap() {
        workspaces = workspacesStorage.workspaces
        showWorkspacesSwitchList = true
    }
    
    // Temporary
    func onTapSwitchWorkspace(details: ObjectDetails) {
        Task {
            try? await activeWorkspaceStorage.setActiveSpace(spaceId: details.spaceId)
        }
    }
    
    // Temporary
    func onTapDeleteWorkspace(details: ObjectDetails) {
    }
    
    // MARK: - Private
    
    private func updateWidgetSubscriptions(workspaceInfo: AccountInfo) {
        models = []
        dataLoaded = false
        objectSubscriptions.removeAll()
        widgetObject = documentService.document(objectId: workspaceInfo.widgetsId)
        
        widgetObject?.widgetsPublisher
            .map { [weak self] blocks in
                self?.dataLoaded = true
                guard let self, let widgetObject = self.widgetObject else { return [] }
                recentStateManagerProtocol.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
                return registry.providers(blocks: blocks, widgetObject: widgetObject)
            }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] models in
                self?.models = models
            }
            .store(in: &objectSubscriptions)
        
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .assign(to: &$hideEditButton)
    }
    
    private func setupSpaceSubscription() {
        activeSpaceSubscription = activeWorkspaceStorage
            .workspaceInfoPublisher
            .receiveOnMain()
            .sink { [weak self] info in
                self?.updateWidgetSubscriptions(workspaceInfo: info)
            }
    }
}
