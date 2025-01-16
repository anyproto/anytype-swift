struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var mode: Mode = .default
    var sort = ObjectSort(relation: .dateUpdated)
    
    enum Mode: Equatable, Hashable, Codable {
        case `default`
    }
}
