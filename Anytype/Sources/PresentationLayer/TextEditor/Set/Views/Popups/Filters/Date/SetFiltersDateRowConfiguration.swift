struct SetFiltersDateRowConfiguration: Identifiable, Equatable {
    let id: Int
    let title: String
    let isSelected: Bool
    let dateType: SetFiltersDateType
    @EquatableNoop var onTap: () -> Void
}
