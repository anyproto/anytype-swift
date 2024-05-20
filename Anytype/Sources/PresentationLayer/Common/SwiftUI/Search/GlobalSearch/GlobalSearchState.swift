struct GlobalSearchState: Equatable {
    var searchText = ""
    var mode: Mode = .default
    var isInitial = true
    
    enum Mode: Equatable {
        case `default`
        case filtered(name: String, limitObjectIds: [String])
    }
}
