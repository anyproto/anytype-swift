import BlocksModels
import AnytypeCore

struct SetTableViewRowData: Identifiable, Hashable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [Relation]
    let showIcon: Bool
    @EquatableNoop var onIconTap: () -> Void
    @EquatableNoop var onRowTap: () -> Void
    
    init(
        id: BlockId,
        title: String,
        icon: ObjectIconImage?,
        relations: [Relation],
        showIcon: Bool,
        onIconTap: @escaping () -> Void,
        onRowTap: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.relations = relations
        self.showIcon = showIcon
        self.onIconTap = onIconTap
        self.onRowTap = onRowTap
    }
}
