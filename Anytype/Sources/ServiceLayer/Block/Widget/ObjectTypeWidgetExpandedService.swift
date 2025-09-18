import Foundation
import AnytypeCore

protocol ObjectTypeWidgetExpandedServiceProtocol: AnyObject, Sendable {
    func isExpanded(id: String) -> Bool
    func setState(id: String, isExpanded: Bool)
    func clearData()
}

final class ObjectTypeWidgetExpandedService: ObjectTypeWidgetExpandedServiceProtocol, Sendable {
    
    private let expandedIdsStorage = UserDefaultStorage(key: "objectTypeWidgetExpandedIds", defaultValue: Set<String>())
    private var expandedIds: Set<String> {
        get { expandedIdsStorage.value }
        set { expandedIdsStorage.value = newValue }
    }
    
    // MARK: - ObjectTypeWidgetExpandedServiceProtocol
    
    func isExpanded(id: String) -> Bool {
        return expandedIds.contains(id)
    }
    
    func setState(id: String, isExpanded: Bool) {
        if isExpanded {
            expandedIds.insert(id)
        } else {
            expandedIds.remove(id)
        }
    }
    
    func clearData() {
        expandedIds.removeAll()
    }
}
