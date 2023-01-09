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
    
    // MARK: - Private
    
    private func setupInitialState() async throws {
        widgetObject.widgetsPublisher
            .map { [weak self] blocks in
                guard let self = self else { return [] }
                return self.registry.providers(blocks: blocks, widgetObject: self.widgetObject)
            }
            .assign(to: &$models)
        
        // Temporary code for delete all widget blocks
//        for child in widgetObject.baseDocument.children {
//            try await blockWidgetService.removeWidgetBlock(contextId: widgetObject.objectId, widgetBlockId: child.id)
//        }
        
        // Temporary code for crate widget blocks in empty object
//        for i in 0..<1 {
//            let info = BlockInformation.empty(content: .link(.empty(targetBlockID: "bafybbczjvvl2aky3lwqpc2l6g2wttyblljhwnhltfcm6bp6fjm5mezzu")))
//            try await blockWidgetService.createWidgetBlock(
//                contextId: widgetObject.objectId,
//                info: info,
//                layout: .tree
//            )
//        }
    }
}
