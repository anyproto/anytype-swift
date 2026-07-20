enum SetKanbanColumnHeaderType {
    case uncategorized
    case status([Property.Status.Option])
    case tag([Property.Tag.Option])
    case checkbox(title: String, isChecked: Bool)

    // Plain-text column name for places that can't render the styled header, like the card's
    // "Move to" menu.
    var title: String {
        switch self {
        case .uncategorized:
            return Loc.Set.View.Kanban.Column.Title.uncategorized
        case let .status(options):
            let title = options.map(\.text).joined(separator: ", ")
            return title.isEmpty ? Loc.Set.View.Kanban.Column.Title.uncategorized : title
        case let .tag(options):
            let title = options.map(\.text).joined(separator: ", ")
            return title.isEmpty ? Loc.Set.View.Kanban.Column.Title.uncategorized : title
        case let .checkbox(title, isChecked):
            return isChecked ?
            Loc.Set.View.Kanban.Column.Title.checked(title) :
            Loc.Set.View.Kanban.Column.Title.unchecked(title)
        }
    }
}

struct SetKanbanMoveTarget: Identifiable {
    let id: String
    let title: String
}
