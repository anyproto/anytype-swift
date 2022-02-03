import BlocksModels
import AnytypeCore

struct SetTableViewRowData: Identifiable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [Relation]
    let screenData: EditorScreenData
    
    init(
        id: BlockId,
        type: EditorViewType,
        title: String,
        icon: ObjectIconImage?,
        allRelations: [Relation],
        colums: [RelationMetadata]
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.screenData = EditorScreenData(pageId: id, type: type)
        
        self.relations = colums.map { colum in
            let relation = allRelations.first { $0.id == colum.key }
            guard let relation = relation else {
                return .unknown(.empty(id: colum.id, name: colum.name))
            }
            
            return relation
        }
    }
}
