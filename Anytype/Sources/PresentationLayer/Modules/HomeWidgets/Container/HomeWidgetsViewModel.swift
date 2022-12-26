import Foundation
import AnytypeCore
import BlocksModels

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private let widgetObject: HomeWidgetsObjectProtocol
    private let registry: HomeWidgetsRegistryProtocol
    private let blockWidgetService: BlockWidgetServiceProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    
    // TODO: Delete from ios 15
    private var appearTask: Task<(), Error>?
    
    init(
        widgetObject: HomeWidgetsObjectProtocol,
        registry: HomeWidgetsRegistryProtocol,
        blockWidgetService: BlockWidgetServiceProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.widgetObject = widgetObject
        self.registry = registry
        self.blockWidgetService = blockWidgetService
        self.output = output
    }
    
    func onAppear() {
        appearTask = Task { [weak self] in
            try await self?.widgetObject.open()
            try await self?.setupInitialState()
        }
    }
    
    deinit {
        appearTask?.cancel()
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
    
    // MARK: - Private
    
    private func setupInitialState() async throws {
        widgetObject.widgetsPublisher
            .map { [weak self] blocks in return self?.registry.providers(blocks: blocks) ?? [] }
            .assign(to: &$models)
        
//        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: "bafybbawyy6dpf4mnjrjncjulsu5c7b4a6mz27wyxbowd4ukf3ga2wz2t")))
//        try await blockWidgetService.createBlockWidget(
//            contextId: widgetObject.objectId,
//            info: info,
//            layout: .tree
//        )
    }
}
