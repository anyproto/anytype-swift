import BlocksModels

struct SetSort: Identifiable, Equatable, Hashable {
    let metadata: RelationMetadata
    let sort: DataviewSort
    
    var id: String { metadata.id }
    
    var type: String {
        switch metadata.format {
        case .tag, .status:
            if sort.type == .asc {
                return "EditSorts.Popup.Sort.Type.Order.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Order.Desc".localized
            }
        case .number, .date, .phone:
            if sort.type == .asc {
                return "EditSorts.Popup.Sort.Type.Number.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Number.Desc".localized
            }
        case .object, .longText, .shortText, .file, .url, .email, .unrecognized:
            if sort.type == .asc {
                return "EditSorts.Popup.Sort.Type.Text.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Text.Desc".localized
            }
        case .checkbox:
            if sort.type == .asc {
                return "EditSorts.Popup.Sort.Type.Checkbox.Asc".localized
            } else {
                return "EditSorts.Popup.Sort.Type.Checkbox.Desc".localized
            }
        }
    }
}
