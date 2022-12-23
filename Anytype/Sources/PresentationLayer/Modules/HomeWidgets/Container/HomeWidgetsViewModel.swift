import Foundation
import AnytypeCore

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private var registry: HomeWidgetsRegistryProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [ObjectLintWidgetViewModel] = []
    
    init(
        widgeetObjectId: String,
        registry: HomeWidgetsRegistryProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.registry = registry
        self.output = output
        
        for i in 0..<20 {
            models.append(ObjectLintWidgetViewModel(name: "Name \(i)"))
        }
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
}
