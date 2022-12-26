import Foundation
import AnytypeCore
import BlocksModels

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private let widgetObject: HomeWidgetsObjectProtocol
    private let registry: HomeWidgetsRegistryProtocol
    private let blockService: BlockActionsServiceSingleProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    
    // TODO: Delete from ios 15
    private var appearTask: Task<(), Error>?
    
    init(
        widgetObject: HomeWidgetsObjectProtocol,
        registry: HomeWidgetsRegistryProtocol,
        blockService: BlockActionsServiceSingleProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.widgetObject = widgetObject
        self.registry = registry
        self.blockService = blockService
        self.output = output
    }
    
    func onAppear() {
        appearTask = Task {
            try await widgetObject.open()
            setupInitialState()
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
    
    private func setupInitialState() {
        models = registry.providers()
        if widgetObject.baseDocument.children.isEmpty {
            let info = BlockInformation.empty(content: .widget(BlockWidget(layout: .link)))
            blockService.add(
                targetId: widgetObject.baseDocument.objectId, info: info, position: .none
            )
        }
    }
}
