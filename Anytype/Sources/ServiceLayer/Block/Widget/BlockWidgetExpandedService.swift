import Foundation
import AnytypeCore

protocol BlockWidgetExpandedServiceProtocol: AnyObject, Sendable {
    func isExpanded(id: String) -> Bool
    func setState(id: String, isExpanded: Bool)
    func deleteState(id: String)
    func clearData()
}

final class BlockWidgetExpandedService: BlockWidgetExpandedServiceProtocol, Sendable {
    
    private let collapsedIdsStorage = UserDefaultStorage(key: "widgetCollapsedIds", defaultValue: Set<String>())
    private var collapsedIds: Set<String> {
        get { collapsedIdsStorage.value }
        set { collapsedIdsStorage.value = newValue }
    }
    
    // MARK: - BlockWidgetExpandedServiceProtocol
    
    func isExpanded(id: String) -> Bool {
        return !collapsedIds.contains(id)
    }
    
    func setState(id: String, isExpanded: Bool) {
        if isExpanded {
            collapsedIds.remove(id)
        } else {
            collapsedIds.insert(id)
        }
    }
    
    func deleteState(id: String) {
        collapsedIds.remove(id)
    }
    
    func clearData() {
        collapsedIds.removeAll()
    }
}
