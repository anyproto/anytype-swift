import Foundation
import Services

@MainActor
protocol CreateWidgetCoordinatorProtocol {
    func startFlow(widgetObjectId: String, spaceId: String, position: WidgetPosition, context: AnalyticsWidgetContext)
}

@MainActor
final class CreateWidgetCoordinator: CreateWidgetCoordinatorProtocol {
    
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let navigationContext: NavigationContextProtocol
    private let widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    
    init(
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol,
        widgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol
    ) {
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.navigationContext = navigationContext
        self.widgetTypeModuleAssembly = widgetTypeModuleAssembly
    }
    
    // MARK: - CreateWidgetCoordinatorProtocol
    
    func startFlow(widgetObjectId: String, spaceId: String, position: WidgetPosition, context: AnalyticsWidgetContext) {
        let searchView = newSearchModuleAssembly.widgetSourceSearchModule(spaceId: spaceId, context: context) { [weak self] source in
            self?.showSelectWidgetType(widgetObjectId: widgetObjectId, source: source, position: position, context: context)
        }
        navigationContext.present(searchView)
    }
    
    // MARK: - Private
    
    private func showSelectWidgetType(widgetObjectId: String, source: WidgetSource, position: WidgetPosition, context: AnalyticsWidgetContext) {
        let module = widgetTypeModuleAssembly.makeCreateWidget(
            widgetObjectId: widgetObjectId,
            source: source,
            position: position,
            context: context
        ) { [weak self] in
            self?.navigationContext.dismissAllPresented()
        }
        navigationContext.present(module)
    }
}
