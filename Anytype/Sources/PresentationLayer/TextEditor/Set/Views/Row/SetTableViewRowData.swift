import BlocksModels
import AnytypeCore

struct SetRowRelation: Identifiable {
    var id: String { key }
    
    let key: String
    let value: String
}

struct SetTableViewRowData: Identifiable {
    let id: BlockId
    let title: String
    let icon: ObjectIconImage?
    let relations: [SetRowRelation]
    
    init(id: BlockId, title: String, icon: ObjectIconImage?, allRelations: [Relation], colums: [SetColumData]) {
        self.id = id
        self.title = title
        self.icon = icon
        
        self.relations = colums.compactMap { colum in
            let relation = allRelations.first { $0.id == colum.key }
            guard let relation = relation else {
                anytypeAssertionFailure("No relation: \(colum) found in \(title)", domain: .editorSet)
                return nil
            }
        
            return SetRowRelation(key: relation.id, value: "\(relation.value)")
        }
    }
}
