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
            return Loc.EditSet.Popup.Sort.Types.ascending
        } else {
            return Loc.EditSet.Popup.Sort.Types.descending
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
