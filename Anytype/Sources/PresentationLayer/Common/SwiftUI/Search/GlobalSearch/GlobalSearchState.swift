struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var mode: Mode = .default
    var sort = ObjectSort(relation: .dateUpdated)
    
    var shouldGroupResults: Bool {
        sort.relation.canGroupByDate && searchText.isEmpty
    }
    
    enum Mode: Equatable, Hashable, Codable {
        case `default`
    }
}
