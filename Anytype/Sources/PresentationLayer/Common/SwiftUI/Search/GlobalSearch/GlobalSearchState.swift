struct GlobalSearchState: Equatable, Hashable {
    var searchText = ""
    var mode: Mode = .default
    var isInitial = true
    
    enum Mode: Equatable, Hashable {
        case `default`
        case filtered(name: String, limitObjectIds: [String])
    }
}
