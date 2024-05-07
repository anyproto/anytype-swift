struct SetSortTypesData: Identifiable {
    var id: String { setSort.id }
    let setSort: SetSort
    let completion: (SetSort, String) -> Void
}
