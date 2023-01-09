import Foundation
import AnytypeCore
import BlocksModels

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private let widgetObject: HomeWidgetsObjectProtocol
    private let registry: HomeWidgetsRegistryProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private let toastPresenter: ToastPresenterProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    @Published var bottomModel: HomeWidgetsBottomPanelViewModel = HomeWidgetsBottomPanelViewModel(buttons: [])
    
    init(
        widgetObject: HomeWidgetsObjectProtocol,
        registry: HomeWidgetsRegistryProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        toastPresenter: ToastPresenterProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.widgetObject = widgetObject
        self.registry = registry
        self.blockWidgetService = blockWidgetService
        self.toastPresenter = toastPresenter
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
    
    // MARK: - Private
    
    private func setupInitialState() async throws {
        widgetObject.widgetsPublisher
            .map { [weak self] blocks in
                guard let self = self else { return [] }
                return self.registry.providers(blocks: blocks, widgetObject: self.widgetObject)
            }
            .assign(to: &$models)
        
        bottomModel = HomeWidgetsBottomPanelViewModel(buttons: [
            HomeWidgetsBottomPanelViewModel.Button(id: "search", image: .Widget.search, onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap search")
            }),
            HomeWidgetsBottomPanelViewModel.Button(id: "new", image: .Widget.add, onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap create object")
            }),
            HomeWidgetsBottomPanelViewModel.Button(id: "space", image: .Widget.add, onTap: { [weak self] in
                self?.toastPresenter.show(message: "On tap space")
           })
        ])
    }
}
