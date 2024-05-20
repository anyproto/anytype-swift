import Foundation

struct WidgetSubmoduleData {
    let widgetBlockId: String
    let widgetObject: BaseDocumentProtocol
    let stateManager: HomeWidgetsStateManagerProtocol
    let output: CommonWidgetModuleOutput?
}
