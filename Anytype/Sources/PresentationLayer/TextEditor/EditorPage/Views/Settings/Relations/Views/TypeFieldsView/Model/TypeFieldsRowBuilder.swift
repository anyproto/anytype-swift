import Services


final class TypeFieldsRowBuilder {
    func build(relations: [Relation], featured: [Relation], systemConflictedRelations: [Relation]) -> [TypeFieldsRow] {
        var data = [TypeFieldsRow]()

        
        data.append(.header(.header))
        if featured.isNotEmpty {
            data.append(
                contentsOf: featured.map { relation in
                        .relation(TypeFieldsRelationRow(section: .header, relation: relation, canDrag: true))
                }
            )
        } else {
            data.append(.emptyRow(.header))
        }

        data.append(.header(.fieldsMenu))
        if relations.isNotEmpty || systemConflictedRelations.isNotEmpty {
            data.append(
                contentsOf: relations.map { relation in
                    .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: relation, canDrag: true))
                }
            )
            
            data.append(
                contentsOf: systemConflictedRelations.map { relation in
                    .relation(TypeFieldsRelationRow(section: .fieldsMenu, relation: relation, canDrag: false))
                }
            )
        } else {
            data.append(.emptyRow(.fieldsMenu))
        }

        return data
    }
}
