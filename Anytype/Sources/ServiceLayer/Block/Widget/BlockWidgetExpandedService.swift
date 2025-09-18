import Foundation
import AnytypeCore

protocol ExpandedServiceProtocol: AnyObject, Sendable {
    func isExpanded(id: String, defaultValue: Bool) -> Bool
    func setState(id: String, isExpanded: Bool)
    func clearData()
}

final class ExpandedService: ExpandedServiceProtocol, Sendable {
    
    private let expandedStorage = UserDefaultStorage(key: "expandedIds", defaultValue: Dictionary<String, Bool>())
    
    // MARK: - BlockWidgetExpandedServiceProtocol
    
    func isExpanded(id: String, defaultValue: Bool) -> Bool {
        return expandedStorage.value[id] ?? defaultValue
    }
    
    func setState(id: String, isExpanded: Bool) {
        expandedStorage.value[id] = isExpanded
    }
    
    func clearData() {
        expandedStorage.value.removeAll()
    }
}
