import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    // MARK: - DI
    
    private let info: AccountInfo
    private let registry: HomeWidgetsRegistryProtocol
    private lazy var widgetObject = documentService.document(objectId: info.widgetsId)
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionService: ObjectActionsServiceProtocol
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: AccountParticipantsStorageProtocol
    
    private let recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    
    private weak var output: HomeWidgetsModuleOutput?
    
    // MARK: - State
    
    @Published var models: [HomeWidgetSubmoduleModel] = []
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var dataLoaded: Bool = false
    @Published var wallpaper: BackgroundType = .default
    
    var spaceId: String { info.accountSpaceId }
    
    init(
        info: AccountInfo,
        registry: HomeWidgetsRegistryProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        recentStateManagerProtocol: HomeWidgetsRecentStateManagerProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.info = info
        self.registry = registry
        self.stateManager = stateManager
        self.recentStateManagerProtocol = recentStateManagerProtocol
        self.output = output
        subscribeOnWallpaper()
        setupInitialState()
    }
    
    func startWidgetObjectTask() async {
        for await _ in widgetObject.syncPublisher.values {
            let blocks = widgetObject.children.filter(\.isWidget)
            recentStateManagerProtocol.setupRecentStateIfNeeded(blocks: blocks, widgetObject: widgetObject)
            let providers = registry.providers(blocks: blocks, widgetObject: widgetObject)
            
            guard providers != models else { continue }
            
            models = providers
            dataLoaded = true
        }
    }
    
    func startParticipantTask() async {
        for await canEdit in accountParticipantStorage.canEditPublisher(spaceId: info.accountSpaceId).values {
            stateManager.setHomeState(canEdit ? .readwrite : .readonly)
        }
    }
    
    func onEditButtonTap() {
        AnytypeAnalytics.instance().logEditWidget()
        stateManager.setHomeState(.editWidgets)
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
    
    func submoduleOutput() -> CommonWidgetModuleOutput? {
        output
    }
    
    func onCreateWidgetSelected() {
        output?.onCreateWidgetSelected(context: .editor)
    }
    
    // TODO: Delete after migration.
    func onHomeStateChanged() {
        if stateManager.homeState != homeState {
            stateManager.setHomeState(homeState)
        }
    }
    
    // MARK: - Private
    
    private func setupInitialState() {
        stateManager.homeStatePublisher
            .receiveOnMain()
            .assign(to: &$homeState)
    }
    
    private func subscribeOnWallpaper() {
        UserDefaultsConfig.wallpaperPublisher(spaceId: info.accountSpaceId)
            .receiveOnMain()
            .assign(to: &$wallpaper)
    }
}
