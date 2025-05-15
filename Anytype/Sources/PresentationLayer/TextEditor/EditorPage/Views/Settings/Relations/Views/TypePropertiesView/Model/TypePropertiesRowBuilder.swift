import Services


final class TypePropertiesRowBuilder {
    func build(relations: [Relation], featured: [Relation], hidden: [Relation], systemConflictedRelations: [Relation]) -> [TypePropertiesRow] {
        var data = [TypePropertiesRow]()

        
        data.append(.header(.header))
        if featured.isNotEmpty {
            data.append(
                contentsOf: featured.map { relation in
                    .relation(TypePropertiesRelationRow(section: .header, relation: relation, canDrag: true))
                }
            )
        } else {
            data.append(.emptyRow(.header))
        }

        data.append(.header(.fieldsMenu))
        if relations.isNotEmpty {
            data.append(
                contentsOf: relations.map { relation in
                    .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: relation, canDrag: true))
                }
            )
        } else {
            data.append(.emptyRow(.fieldsMenu))
        }
        
        data.append(.header(.hidden))
        if hidden.isNotEmpty || systemConflictedRelations.isNotEmpty {
            data.append(
                contentsOf: hidden.map { relation in
                        .relation(TypePropertiesRelationRow(section: .hidden, relation: relation, canDrag: true))
                }
            )
            
            data.append(
                contentsOf: systemConflictedRelations.map { relation in
                        .relation(TypePropertiesRelationRow(section: .hidden, relation: relation, canDrag: false))
                }
            )
        } else {
            data.append(.emptyRow(.hidden))
        }

        return data
    }
}
