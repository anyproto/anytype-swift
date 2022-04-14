import BlocksModels
import AnytypeCore

struct SetTableViewRowData: Identifiable, Hashable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [Relation]
    let screenData: EditorScreenData
    let showIcon: Bool
    
    init(
        id: BlockId,
        title: String,
        icon: ObjectIconImage?,
        relations: [Relation],
        screenData: EditorScreenData,
        showIcon: Bool
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.relations = relations
        self.screenData = screenData
        self.showIcon = showIcon
    }
}
