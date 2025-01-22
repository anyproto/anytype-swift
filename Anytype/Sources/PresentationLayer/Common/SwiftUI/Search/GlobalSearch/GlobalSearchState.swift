struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var sort = ObjectSort(relation: .dateUpdated)
    var section = ObjectTypeSection.all
    
    var shouldGroupResults: Bool {
        sort.relation.canGroupByDate && searchText.isEmpty
    }
}
