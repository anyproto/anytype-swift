import Foundation
import BlocksModels

@MainActor
protocol HomeWidgetsRegistryProtocol {
    func providers(blocks: [BlockInformation]) -> [HomeWidgetProviderProtocol]
}

@MainActor
final class HomeWidgetsRegistry: HomeWidgetsRegistryProtocol {

    // MARK: - HomeWidgetsRegistryProtocol
    
    func providers(blocks: [BlockInformation]) -> [HomeWidgetProviderProtocol] {
        return blocks.compactMap { block in
            guard case let .widget(widget) = block.content else { return nil }
            
            switch widget.layout {
            case .link:
                return ObjectTreeWidgetProvider(widgetBlockId: "Block Link \(block.id)")
            case .tree:
                return ObjectTreeWidgetProvider(widgetBlockId: "Block Tree \(block.id)")
            }
        }
    }
}
