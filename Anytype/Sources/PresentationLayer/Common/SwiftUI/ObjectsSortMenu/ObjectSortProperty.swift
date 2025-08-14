import Services

enum ObjectSortProperty: String, CaseIterable, Codable {
    case dateUpdated
    case dateCreated
    case name
    
    var title: String {
        switch self {
        case .dateUpdated:
            Loc.AllObjects.Sort.dateUpdated
        case .dateCreated:
            Loc.AllObjects.Sort.dateCreated
        case .name:
            Loc.name
        }
    }
    
    var key: BundledPropertyKey {
        switch self {
        case .dateUpdated:
            return BundledPropertyKey.lastModifiedDate
        case .dateCreated:
            return BundledPropertyKey.createdDate
        case .name:
            return BundledPropertyKey.name
        }
    }
    
    var defaultSortType: DataviewSort.TypeEnum {
        switch self {
        case .dateUpdated:
            return .desc
        case .dateCreated:
            return .desc
        case .name:
            return .asc
        }
    }
    
    var availableSortTypes: [DataviewSort.TypeEnum] {
        switch self {
        case .dateUpdated, .dateCreated:
            return DataviewSort.TypeEnum.allAvailableCases.reversed()
        case .name:
            return DataviewSort.TypeEnum.allAvailableCases
        }
    }
    
    var canGroupByDate: Bool {
        switch self {
        case .dateUpdated, .dateCreated:
            return true
        case .name:
            return false
        }
    }
    
    var analyticsValue: String {
        switch self {
        case .dateUpdated:
            "Updated"
        case .dateCreated:
            "Created"
        case .name:
            "Name"
        }
    }
    
    func titleFor(sortType: DataviewSort.TypeEnum) -> String {
        switch self {
        case .dateUpdated, .dateCreated:
            return sortType == .asc ? Loc.AllObjects.Sort.Date.asc : Loc.AllObjects.Sort.Date.desc
        case .name:
            return sortType == .asc ? Loc.AllObjects.Sort.Name.asc : Loc.AllObjects.Sort.Name.desc
        }
    }
}
