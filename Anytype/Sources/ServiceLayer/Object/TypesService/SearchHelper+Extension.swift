import Services

extension SearchHelper {
    
    static func defaultObjectTypeSort(isChat: Bool) -> [DataviewSort] {
        let nameSort = SearchHelper.sort(relation: .name, type: .asc)
        
        let customSort = SearchHelper.customSort(relationKey: BundledPropertyKey.uniqueKey.rawValue, values: [
            ObjectTypeUniqueKey.page.value,
            ObjectTypeUniqueKey.task.value,
            ObjectTypeUniqueKey.collection.value,
            ObjectTypeUniqueKey.set.value,
            ObjectTypeUniqueKey.bookmark.value,
            ObjectTypeUniqueKey.note.value
        ])
        
        let orderIdSort = SearchHelper.sort(relation: .orderId, type: .asc)
        
        return [orderIdSort, customSort, nameSort]
    }
}
