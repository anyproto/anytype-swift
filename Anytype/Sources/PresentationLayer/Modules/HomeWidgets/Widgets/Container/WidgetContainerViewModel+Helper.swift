import Foundation
import Services

extension WidgetContainerViewModel {
    
    // DI helper
    
    convenience init(
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol,
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        contentModel: ContentVM,
        output: CommonWidgetModuleOutput?
    ) {
        self.init(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            blockWidgetService: serviceLocator.blockWidgetService(),
            stateManager: stateManager,
            blockWidgetExpandedService: serviceLocator.blockWidgetExpandedService(),
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            alertOpener: uiHelpersDI.alertOpener(),
            contentModel: contentModel,
            output: output
        )
    }
}
