import Services

struct SetSort: Identifiable, Equatable, Hashable {
    let relationDetails: PropertyDetails
    let sort: DataviewSort
    
    var id: String { relationDetails.id }
    
    func typeTitle() -> String? {
        typeTitle(for: sort.type)
    }
    
    func typeTitle(for sortType: DataviewSort.TypeEnum) -> String? {
        switch sortType {
        case .asc:
            return Loc.EditSet.Popup.Sort.Types.ascending
        case .desc:
            return Loc.EditSet.Popup.Sort.Types.descending
        case .UNRECOGNIZED(_), .custom:
            return nil
        }
    }
    
    func emptyTypeTitle(for sortEmptyType: DataviewSort.EmptyType) -> String? {
        switch sortEmptyType {
        case .start:
            return Loc.EditSet.Popup.Sort.EmptyTypes.start
        case .end:
            return Loc.EditSet.Popup.Sort.EmptyTypes.end
        case .UNRECOGNIZED(_), .notSpecified:
            return nil
        }
    }
}

extension DataviewSort.TypeEnum {
    static let allAvailableCases: [DataviewSort.TypeEnum] = [.asc, .desc]
    
    var analyticValue: String {
        switch self {
        case .asc: return "Asc"
        case .desc: return "Desc"
        case .custom: return "Custom"
        case .UNRECOGNIZED(let value): return "UNRECOGNIZED \(value)"
        }
    }
}

extension DataviewSort.EmptyType {
    static let allAvailableCases: [DataviewSort.EmptyType] = [.end, .start]
    
    var analyticValue: String {
        switch self {
        case .start: return "Start"
        case .end: return "End"
        case .notSpecified: return "None"
        case .UNRECOGNIZED(let value): return "UNRECOGNIZED \(value)"
        }
    }
}
