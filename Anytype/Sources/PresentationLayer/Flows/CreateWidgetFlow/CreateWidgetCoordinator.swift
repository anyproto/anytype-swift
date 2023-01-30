import Foundation
import BlocksModels

@MainActor
protocol CreateWidgetCoordinatorProtocol {
    func startFlow(widgetObjectId: String)
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
    
    func startFlow(widgetObjectId: String) {
        let searchView = newSearchModuleAssembly.objectsSearchModule(
            title: Loc.Widgets.sourceSearch,
            style: .default,
            selectionMode: .singleItem,
            excludedObjectIds: [],
            limitedObjectType: [],
            onSelect: { [weak self] allDetails in
                guard let details = allDetails.first else { return }
                self?.showSelectWidgetType(widgetObjectId: widgetObjectId, details: details)
            }
        )
        navigationContext.presentSwiftUIView(view: searchView)
    }
    
    // MARK: - Private
    
    private func showSelectWidgetType(widgetObjectId: String, details: ObjectDetails) {
        let module = widgetTypeModuleAssembly.makeCreateWidget(widgetObjectId: widgetObjectId, sourceObjectDetails: details) { [weak self] in
            self?.navigationContext.dismissAllPresented()
        }
        navigationContext.present(module)
    }
}
