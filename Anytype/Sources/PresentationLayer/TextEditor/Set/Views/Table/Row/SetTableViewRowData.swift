import BlocksModels
import AnytypeCore

struct SetRowRelation: Identifiable {
    var id: String { key }
    
    let key: String
    let value: Relation
}

struct SetTableViewRowData: Identifiable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [SetRowRelation]
    let screenData: EditorScreenData
    
    init(id: BlockId, type: EditorViewType, title: String, icon: ObjectIconImage?, allRelations: [Relation], colums: [SetColumData]) {
        self.id = id
        self.title = title
        self.icon = icon
        self.screenData = EditorScreenData(pageId: id, type: type)
        
        self.relations = colums.compactMap { colum in
            let relation = allRelations.first { $0.id == colum.key }
            guard let relation = relation else {
                anytypeAssertionFailure("No relation: \(colum) found in \(title)", domain: .editorSet)
                return nil
            }
        
            return SetRowRelation(key: relation.id, value: relation)
        }
    }
}
