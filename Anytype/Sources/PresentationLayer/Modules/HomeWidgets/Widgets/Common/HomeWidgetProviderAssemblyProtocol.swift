import Foundation

protocol HomeWidgetProviderAssemblyProtocol: AnyObject {
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol
    ) -> HomeSubmoduleProviderProtocol
}
