import BlocksModels

struct SetSort: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let sort: DataviewSort
    
    var id: String { metadata.id }
    
    func typeTitle() -> String {
        typeTitle(for: sort.type)
    }
    
    func typeTitle(for sortType: DataviewSort.TypeEnum) -> String {
        if sortType == .asc {
            return "EditSorts.Popup.Sort.Type.Ascending".localized
        } else {
            return "EditSorts.Popup.Sort.Type.Descending".localized
        }
    }
}

extension Array where Element == DataviewSort {
    func uniqued() -> [DataviewSort] {
        var dict = [String: Bool]()

        return filter {
            dict.updateValue(true, forKey: $0.relationKey) == nil
        }
    }
}
