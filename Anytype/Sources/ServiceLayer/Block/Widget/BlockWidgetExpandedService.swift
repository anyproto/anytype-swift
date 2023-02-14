import Foundation
import AnytypeCore

protocol BlockWidgetExpandedServiceProtocol: AnyObject {
    func isExpanded(widgetBlockId: String) -> Bool
    func setState(widgetBlockId: String, isExpanded: Bool)
    func clearData()
}

final class BlockWidgetExpandedService: BlockWidgetExpandedServiceProtocol {
    
    @UserDefault("widgetCollapsedIds", defaultValue: [])
    private var collapsedIds: Set<String>
    
    // MARK: - BlockWidgetExpandedServiceProtocol
    
    func isExpanded(widgetBlockId: String) -> Bool {
        return !collapsedIds.contains(widgetBlockId)
    }
    
    func setState(widgetBlockId: String, isExpanded: Bool) {
        if isExpanded {
            collapsedIds.remove(widgetBlockId)
        } else {
            collapsedIds.insert(widgetBlockId)
        }
    }
    
    func clearData() {
        collapsedIds.removeAll()
    }
}
