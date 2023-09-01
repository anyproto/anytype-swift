enum EditorSetViewSettingsItem: Identifiable, Equatable {
    case value(EditorSetViewSettingsValueItem)
    case toggle(EditorSetViewSettingsToggleItem)
    case context(EditorSetViewSettingsContextItem)
    
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

struct EditorSetViewSettingsValueItem: Equatable {
    let title: String
    let value: String
    @EquatableNoop var onTap: () -> Void
}

struct EditorSetViewSettingsToggleItem: Equatable {
    let title: String
    let isSelected: Bool
    @EquatableNoop var onChange: (Bool) -> Void
}

struct EditorSetViewSettingsContextItem: Equatable {
    let title: String
    let value: String
    let options: [Option]
    
    struct Option: Equatable, Identifiable {
        let id: String
        @EquatableNoop var onTap: () -> Void
    }
}
