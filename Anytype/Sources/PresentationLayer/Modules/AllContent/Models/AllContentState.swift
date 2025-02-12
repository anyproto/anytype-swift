struct AllContentState: Equatable, Hashable {
    var mode = AllContentMode.allContent { didSet { resetLimit() } }
    var section = ObjectTypeSection.pages { didSet { resetLimit()} }
    var sort = ObjectSort(relation: .dateUpdated) { didSet { resetLimit() } }
    var limitedObjectsIds: [String]? = nil { didSet { resetLimit() } }
    var limit = Constants.limit
    
    mutating func updateLimit() {
        limit += Constants.limit
    }
    
    mutating func resetLimit() {
        limit = Constants.limit
    }
    
    var scrollId: String {
        mode.rawValue + section.rawValue + sort.id
    }
    
    private enum Constants {
        static let limit = 100
    }
}
