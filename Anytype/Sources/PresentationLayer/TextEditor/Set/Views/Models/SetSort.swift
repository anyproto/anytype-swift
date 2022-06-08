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
                return "EditSorts.Popup.Sort.Type.Order.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Order.Desc".localized
            }
        case .number, .date, .phone:
            if sortType == .asc {
                return "EditSorts.Popup.Sort.Type.Number.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Number.Desc".localized
            }
        case .longText, .shortText, .file, .url, .email, .unrecognized:
            if sortType == .asc {
                return "EditSorts.Popup.Sort.Type.Text.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Text.Desc".localized
            }
        case .checkbox:
            if sortType == .asc {
                return "EditSorts.Popup.Sort.Type.Checkbox.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Checkbox.Desc".localized
            }
        }
    }
}
