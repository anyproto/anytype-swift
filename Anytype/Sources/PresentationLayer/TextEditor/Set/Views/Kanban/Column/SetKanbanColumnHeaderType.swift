enum SetKanbanColumnHeaderType {
    case uncategorized
    case status([Property.Status.Option])
    case tag([Property.Tag.Option])
    case checkbox(title: String, isChecked: Bool)
}
