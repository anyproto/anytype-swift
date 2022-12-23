import Foundation
import AnytypeCore

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private let widgetObject: HomeWidgetsObjectProtocol
    private let registry: HomeWidgetsRegistryProtocol
    private weak var output: HomeWidgetsModuleOutput?
    
    @Published var models: [HomeWidgetProviderProtocol] = []
    
    init(
        widgetObject: HomeWidgetsObjectProtocol,
        registry: HomeWidgetsRegistryProtocol,
        output: HomeWidgetsModuleOutput?
    ) {
        self.widgetObject = widgetObject
        self.registry = registry
        self.output = output
    }
    
    func onAppear() {
        models = registry.providers()
        Task {
            try await widgetObject.open()
        }
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
}
