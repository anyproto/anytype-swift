enum SetViewSettingsItem: Identifiable, Equatable {
    case value(SetViewSettingsValueItem)
    case toggle(SetViewSettingsToggleItem)
    case context(SetViewSettingsContextItem)
    
    var id: String {
        switch self {
        case let .value(item):
            return item.title
        case let .toggle(item):
            return item.title
        case let .context(item):
            return item.title
        }
    }
}

struct SetViewSettingsValueItem: Equatable {
    let title: String
    let value: String
    @EquatableNoop var onTap: () -> Void
}

struct SetViewSettingsToggleItem: Equatable {
    let title: String
    let isSelected: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}

struct SetViewSettingsContextItem: Equatable {
    let title: String
    let value: String
    let options: [Option]
    
    struct Option: Equatable, Identifiable {
        let id: String
        @EquatableNoop var onTap: () -> Void
    }
}
