struct GlobalSearchState: Equatable {
    var searchText = ""
    var mode: Mode = .default
    
    enum Mode: Equatable {
        case `default`
        case filtered(name: String, limitObjectIds: [String])
    }
}
