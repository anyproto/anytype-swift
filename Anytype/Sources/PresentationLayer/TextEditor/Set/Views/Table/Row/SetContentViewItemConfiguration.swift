import BlocksModels
import AnytypeCore

struct SetContentViewItemConfiguration: Identifiable, Hashable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [Relation]
    let showIcon: Bool
    let coverFit: Bool
    @EquatableNoop var onIconTap: () -> Void
    @EquatableNoop var onItemTap: () -> Void
    
    init(
        id: BlockId,
        title: String,
        icon: ObjectIconImage?,
        relations: [Relation],
        showIcon: Bool,
        coverFit: Bool,
        onIconTap: @escaping () -> Void,
        onItemTap: @escaping () -> Void
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.relations = relations
        self.showIcon = showIcon
        self.coverFit = coverFit
        self.onIconTap = onIconTap
        self.onItemTap = onItemTap
    }
}
