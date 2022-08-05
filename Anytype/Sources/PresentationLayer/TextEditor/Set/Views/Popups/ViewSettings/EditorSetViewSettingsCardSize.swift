import BlocksModels

struct EditorSetViewSettingsCardSize {
    let title: String
    let value: String
    @EquatableNoop var onTap: () -> Void
}

extension DataviewViewSize {
    var value: String {
        switch self {
        case .small:
            return Loc.Set.View.Settings.CardSize.Small.title
        case .large:
            return Loc.Set.View.Settings.CardSize.Large.title
        default:
            return ""
        }
    }
    
    static let availableCases = [DataviewViewSize.small, DataviewViewSize.large]
}
