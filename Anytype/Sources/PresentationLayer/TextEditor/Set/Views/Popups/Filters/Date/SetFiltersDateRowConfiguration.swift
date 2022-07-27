struct SetFiltersDateRowConfiguration: Identifiable, Equatable {
    let id: Int
    let title: String
    let isChecked: Bool
    @EquatableNoop var onTap: () -> Void
}
