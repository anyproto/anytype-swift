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
    private let blockWidgetService: BlockWidgetServiceProtocol
    
    init(
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        navigationContext: NavigationContextProtocol,
        blockWidgetService: BlockWidgetServiceProtocol
    ) {
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.navigationContext = navigationContext
        self.blockWidgetService = blockWidgetService
    }
    
    // MARK: - CreateWidgetCoordinatorProtocol
    
    func startFlow(widgetObjectId: String) {
        let searchView = newSearchModuleAssembly.objectsSearchModule(
            style: .default,
            selectionMode: .singleItem,
            excludedObjectIds: [],
            limitedObjectType: [],
            onSelect: { ids in
                guard let id = ids.first else { return }
                Task { [weak self] in
                    await self?.createWidget(widgetObjectId:widgetObjectId, linkObjectId: id)
                }
            }
        )
        navigationContext.presentSwiftUIView(view: searchView)
    }
    
    // MARK: - Private
    
    private func createWidget(widgetObjectId: String, linkObjectId: String) async {
        let info = BlockInformation.empty(content: .link(.empty(targetBlockID: linkObjectId)))
        try? await blockWidgetService.createWidgetBlock(
            contextId: widgetObjectId,
            info: info,
            layout: .tree
        )
        navigationContext.dismissAllPresented()
    }
}
