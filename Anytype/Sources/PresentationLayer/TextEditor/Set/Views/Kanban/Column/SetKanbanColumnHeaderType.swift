enum SetKanbanColumnHeaderType {
    case uncategorized
    case status([Relation.Status.Option])
    case tag([Relation.Tag.Option])
    case checkbox(title: String, isChecked: Bool)
}
