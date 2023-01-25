import Foundation
import AnytypeCore
import BlocksModels

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private let widgetObject: HomeWidgetsObjectProtocol
    private let registry: HomeWidgetsRegistryProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let accountManager: AccountManager
    private let toastPresenter: ToastPresenterProtocol
    private let stateManager: HomeWidgetsStateManagerProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    @Published var bottomPanelProvider: HomeWidgetProviderProtocol
    
    init(
        widgetObject: HomeWidgetsObjectProtocol,
        registry: HomeWidgetsRegistryProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        accountManager: AccountManager,
        bottomPanelProviderAssembly: HomeBottomPanelProviderAssemblyProtocol,
        toastPresenter: ToastPresenterProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.widgetObject = widgetObject
        self.registry = registry
        self.blockWidgetService = blockWidgetService
        self.accountManager = accountManager
        self.bottomPanelProvider = bottomPanelProviderAssembly.make()
        self.toastPresenter = toastPresenter
        self.stateManager = stateManager
        self.output = output
    }
    
    func onAppear() {
        Task { [weak self] in
            try await self?.widgetObject.open()
            try await self?.setupInitialState()
        }
    }
    
    func onDisappear() {
        Task { [weak self] in
            try await self?.widgetObject.close()
        }
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
    
    func onCreateWidgetTap() {
        output?.onCreateWidgetSelected()
    }
    
    func onSpaceIconChangeTap() {
        output?.onSpaceIconChangeSelected(objectId: accountManager.account.info.accountSpaceId)
    }
    
    func onEditButtonTap() {
        stateManager.setEditState(true)
    }
    
    // MARK: - Private
    
    private func setupInitialState() async throws {
        widgetObject.widgetsPublisher
            .map { [weak self] blocks in
                guard let self = self else { return [] }
                return self.registry.providers(blocks: blocks, widgetObject: self.widgetObject)
            }
            .assign(to: &$models)
    }
}
