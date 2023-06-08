import Foundation

final class HomeWidgetCommonProviderAssembly: HomeWidgetProviderAssemblyProtocol {
    
    private let widgetAssembly: HomeWidgetCommonAssemblyProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    init(widgetAssembly: HomeWidgetCommonAssemblyProtocol, output: CommonWidgetModuleOutput?) {
        self.widgetAssembly = widgetAssembly
        self.output = output
    }
    
    // MARK: - HomeWidgetProviderAssemblyProtocol
    
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeSubmoduleProviderProtocol {
        return HomeWidgetCommonProvider(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            widgetAssembly: widgetAssembly,
            stateManager: stateManager,
            output: output
        )
    }
}
