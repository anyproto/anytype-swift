import Services

struct SetFilterConditions: Identifiable {
    var id: String { filter.id }
    let filter: SetFilter
    let completion: (DataviewFilter.Condition) -> Void
}
