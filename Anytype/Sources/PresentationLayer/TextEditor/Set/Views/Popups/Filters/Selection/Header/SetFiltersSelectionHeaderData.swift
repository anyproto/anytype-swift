import Services

struct SetFiltersSelectionHeaderData {
    let filter: SetFilter
    let onConditionChanged: (DataviewFilter.Condition) -> Void
}
