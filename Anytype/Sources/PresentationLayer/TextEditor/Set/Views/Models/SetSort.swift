import BlocksModels

struct SetSort: Identifiable, Equatable, Hashable {
    let relationDetails: RelationDetails
    let sort: DataviewSort
    
    var id: String { relationDetails.id }
    
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

extension DataviewSort.TypeEnum {
    static let allAvailableCases: [DataviewSort.TypeEnum] = [.asc, .desc]
}
