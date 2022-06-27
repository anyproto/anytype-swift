import BlocksModels

struct SetSort: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let sort: DataviewSort
    
    var id: String { metadata.id }
    
    func typeTitle() -> String {
        typeTitle(for: sort.type)
    }
    
    func typeTitle(for sortType: DataviewSort.TypeEnum) -> String {
        switch metadata.format {
        case .object, .tag, .status:
            if sortType == .asc {
                return Loc.EditSorts.Popup.SortType.Order.asc
            } else {
                return Loc.EditSorts.Popup.SortType.Order.desc
            }
        case .number, .date, .phone:
            if sortType == .asc {
                return Loc.EditSorts.Popup.SortType.Number.asc
            } else {
                return Loc.EditSorts.Popup.SortType.Number.desc
            }
        case .longText, .shortText, .file, .url, .email, .unrecognized:
            if sortType == .asc {
                return Loc.EditSorts.Popup.SortType.Text.asc
            } else {
                return Loc.EditSorts.Popup.SortType.Text.desc
            }
        case .checkbox:
            if sortType == .asc {
                return Loc.EditSorts.Popup.SortType.Checkbox.asc
            } else {
                return Loc.EditSorts.Popup.SortType.Checkbox.desc
            }
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
