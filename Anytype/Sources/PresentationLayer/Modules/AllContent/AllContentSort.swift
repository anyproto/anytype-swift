import Services

struct AllContentSort: Equatable, Hashable {
    let relation: Relation
    var type: DataviewSort.TypeEnum
    
    var id: String { relation.rawValue + "\(type.rawValue)" }
    
    init(relation: Relation, type: DataviewSort.TypeEnum? = nil) {
        self.relation = relation
        self.type = type ?? relation.defaultSortType
    }
    
    func asDataviewSort() -> DataviewSort {
        SearchHelper.sort(
            relation: relation.key,
            type: type
        )
    }
    
    enum Relation: String, CaseIterable {
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
        
        func titleFor(sortType: DataviewSort.TypeEnum) -> String {
            switch self {
            case .dateUpdated, .dateCreated:
                return sortType == .asc ? Loc.AllContent.Sort.Date.asc : Loc.AllContent.Sort.Date.desc
            case .name:
                return sortType == .asc ? Loc.AllContent.Sort.Name.asc : Loc.AllContent.Sort.Name.desc
            }
        }
    }
}
