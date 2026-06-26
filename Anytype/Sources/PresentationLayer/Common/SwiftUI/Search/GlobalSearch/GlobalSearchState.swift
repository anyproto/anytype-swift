struct GlobalSearchState: Equatable, Hashable, Codable {
    var searchText = ""
    var sort = ObjectSort(relation: .dateUpdated)
    var section = ObjectTypeSection.all
    
    var shouldGroupResults: Bool {
        sort.relation.canGroupByDate && searchText.isEmpty
    }

    // Identity used to reset the results List scroll position only when the
    // section or sort changes. Excludes `searchText` so typing diffs rows by id
    // instead of tearing down the whole List on every keystroke.
    var scrollResetKey: ScrollResetKey {
        ScrollResetKey(section: section, sort: sort)
    }

    struct ScrollResetKey: Equatable, Hashable {
        let section: ObjectTypeSection
        let sort: ObjectSort
    }
}
