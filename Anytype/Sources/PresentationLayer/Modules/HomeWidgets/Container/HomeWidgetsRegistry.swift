import Foundation

@MainActor
protocol HomeWidgetsRegistryProtocol {
    func providers() -> [HomeWidgetProviderProtocol]
}

@MainActor
final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers() -> [HomeWidgetProviderProtocol] {
        
        let providers = (0..<50).map {
            // TODO: Detect block type and create specific provider
            return ObjectTreeWidgetProvider(widgetBlockId: "Block\($0)")
        }
        return providers
    }
}
