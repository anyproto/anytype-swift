import Services

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

extension DataviewSort.TypeEnum {
    static let allAvailableCases: [DataviewSort.TypeEnum] = [.asc, .desc]
    
    var stringValue: String {
        switch self {
        case .asc: return "Asc"
        case .desc: return "Desc"
        case .custom: return "Custom"
        case .UNRECOGNIZED(let value): return "UNRECOGNIZED \(value)"
        }
    }
}
