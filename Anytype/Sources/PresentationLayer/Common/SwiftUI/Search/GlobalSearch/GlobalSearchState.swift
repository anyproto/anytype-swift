struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var mode: Mode = .default
    
    enum Mode: Equatable, Hashable, Codable {
        case `default`
        case filtered(FilteredData)
    }
}

struct FilteredData: Equatable, Hashable, Codable {
    let id: String
    let name: String
    let limitObjectIds: [String]
}
