import Foundation

@MainActor
protocol HomeWidgetProviderAssemblyProtocol: AnyObject {
    func make(widgetBlockId: String, widgetObject: HomeWidgetsObjectProtocol) -> HomeWidgetProviderProtocol
}
