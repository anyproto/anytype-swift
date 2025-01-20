import Services

enum ObjectSortRelation: String, CaseIterable, Codable {
    case dateUpdated
    case dateCreated
    case name
    
    var title: String {
        switch self {
        case .dateUpdated:
            Loc.AllContent.Sort.dateUpdated
        case .dateCreated:
            Loc.AllContent.Sort.dateCreated
        case .name:
            Loc.name
        }
    }
    
    var key: BundledRelationKey {
        switch self {
        case .dateUpdated:
            return BundledRelationKey.lastModifiedDate
        case .dateCreated:
            return BundledRelationKey.createdDate
        case .name:
            return BundledRelationKey.name
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
            return sortType == .asc ? Loc.AllContent.Sort.Date.asc : Loc.AllContent.Sort.Date.desc
        case .name:
            return sortType == .asc ? Loc.AllContent.Sort.Name.asc : Loc.AllContent.Sort.Name.desc
        }
    }
}
