import BlocksModels
import AnytypeCore

struct SetRowRelation: Identifiable {
    var id: String { key }
    
    let key: String
    let value: String
}

struct SetTableViewRow: Identifiable {
    let id: BlockId
    let title: String
    let relations: [SetRowRelation]
    
    init(id: BlockId, title: String, allRelations: [Relation], colums: [RelationMetadata]) {
        self.id = id
        self.title = title
        
        self.relations = colums.compactMap { columRelation in
            let relation = allRelations.first { $0.id == columRelation.id }
            guard let relation = relation else {
                anytypeAssertionFailure("No relation: \(columRelation) found in \(title)", domain: .editorSet)
                return nil
            }
        
            return SetRowRelation(key: relation.id, value: "\(relation.value)")
        }
    }
}
