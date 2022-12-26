import Foundation
import AnytypeCore

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private var registry: HomeWidgetsRegistryProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    
    init(
        widgeetObjectId: String,
        registry: HomeWidgetsRegistryProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.registry = registry
        self.output = output
    }
    
    func onAppear() {
        models = registry.providers()
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
}
