struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var mode: Mode = .default
    
    enum Mode: Equatable, Hashable, Codable {
        case `default`
    }
}
