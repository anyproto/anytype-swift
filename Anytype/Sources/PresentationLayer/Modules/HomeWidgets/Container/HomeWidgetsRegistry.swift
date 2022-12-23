import Foundation

@MainActor
protocol HomeWidgetsRegistryProtocol {
    func providers() -> [HomeWidgetProviderProtocol]
}

@MainActor
final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    func providers() -> [HomeWidgetProviderProtocol] {
        
        let providers = (0..<50).map {
            // TODO: Detect block type and create specific provider
            return ObjectLintWidgetProvider(widgetBlockId: "Block\($0)")
        }
        return providers
    }
}
