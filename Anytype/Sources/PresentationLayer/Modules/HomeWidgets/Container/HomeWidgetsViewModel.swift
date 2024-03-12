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
    private let documentService: OpenedDocumentsProviderProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    // MARK: - State
    
    @Published var models: [HomeWidgetSubmoduleModel] = []
    @Published var bottomPanelProvider: HomeSubmoduleProviderProtocol
    @Published var hideEditButton: Bool = false
    @Published var dataLoaded: Bool = false
    @Published var wallpaper: BackgroundType = .default
    
    private var objectSubscriptions = [AnyCancellable]()
    
    init(
        info: AccountInfo,
        registry: HomeWidgetsRegistryProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        bottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        objectActionService: ObjectActionsServiceProtocol,
        recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        documentService: OpenedDocumentsProviderProtocol,
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
        self.output = output
        subscribeOnWallpaper(info: info)
        setupInitialState()
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
    
    func onSpaceSelected() {
        output?.onSpaceSelected()
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
    
    private func subscribeOnWallpaper(info: AccountInfo) {
        UserDefaultsConfig.wallpaperPublisher(spaceId: info.accountSpaceId)
            .receiveOnMain()
            .assign(to: &$wallpaper)
    }
}
