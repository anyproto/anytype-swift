import Foundation
import AnytypeCore
import Services
import Combine

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    // MARK: - DI
    
    private let widgetObject: BaseDocumentProtocol
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
    private var objectSubscriptions = [AnyCancellable]()
    
    init(
        info: AccountInfo,
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
        self.widgetObject = documentService.document(objectId: info.widgetsId)
        self.registry = registry
        self.blockWidgetService = blockWidgetService
        self.bottomPanelProvider = bottomPanelProviderAssembly.make(info: info, stateManager: stateManager)
        self.stateManager = stateManager
        self.objectActionService = objectActionService
        self.recentStateManagerProtocol = recentStateManagerProtocol
        self.documentService = documentService
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.workspaceService = workspaceService
        self.workspacesStorage = workspacesStorage
        self.output = output
    }
    
    func onAppear() {
        setupInitialState()
    }
    
    func onDisappear() {}
    
    func onEditButtonTap() {
        AnytypeAnalytics.instance().logEditWidget()
        stateManager.setEditState(true)
    }
    
    func dropUpdate(from: DropDataElement<HomeWidgetSubmoduleModel>, to: DropDataElement<HomeWidgetSubmoduleModel>) {
        models.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }
    
    func dropFinish(from: DropDataElement<HomeWidgetSubmoduleModel>, to: DropDataElement<HomeWidgetSubmoduleModel>) {
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
    
    private func setupInitialState() {
        widgetObject.widgetsPublisher
            .map { [weak self] blocks -> [HomeWidgetSubmoduleModel] in
                guard let self else { return [] }
                recentStateManagerProtocol.setupRecentStateIfNeeded(blocks: blocks, widgetObject: self.widgetObject)
                return registry.providers(blocks: blocks, widgetObject: widgetObject)
            }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] models in
                self?.models = models
                self?.dataLoaded = true
            }
            .store(in: &objectSubscriptions)
        
        stateManager.isEditStatePublisher
            .receiveOnMain()
            .assign(to: &$hideEditButton)
    }
}
