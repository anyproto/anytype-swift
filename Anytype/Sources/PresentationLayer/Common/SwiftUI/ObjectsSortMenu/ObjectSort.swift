import Services

struct ObjectSort: Equatable, Hashable, Codable {
    var relation: ObjectSortProperty
    var type: DataviewSort.TypeEnum
    
    var id: String { relation.rawValue + "\(type.rawValue)" }
    
    init(relation: ObjectSortProperty, type: DataviewSort.TypeEnum? = nil) {
        self.relation = relation
        self.type = type ?? relation.defaultSortType
    }
    
    func asDataviewSort() -> DataviewSort {
        SearchHelper.sort(
            relation: relation.key,
            type: type
        )
    }
}

extension DataviewSort.TypeEnum: @retroactive Codable {}
