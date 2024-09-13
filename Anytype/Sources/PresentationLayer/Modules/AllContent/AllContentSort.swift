import Services

struct AllContentSort: Equatable, Hashable {
    let relation: Relation
    let type: DataviewSort.TypeEnum
    
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
    
    enum Relation: CaseIterable {
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
    }
}
