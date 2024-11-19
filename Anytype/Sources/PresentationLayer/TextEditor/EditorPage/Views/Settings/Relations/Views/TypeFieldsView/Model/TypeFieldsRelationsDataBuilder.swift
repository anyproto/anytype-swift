final class TypeFieldsRelationsDataBuilder {
    func build(parsedRelations: ParsedRelations) -> [TypeFieldsRelationsData] {
        var data = [TypeFieldsRelationsData]()

        data.append(
            contentsOf: parsedRelations.featuredRelations.enumerated().map { index, relation in
                TypeFieldsRelationsData(relation: relation, relationIndex: index, section: .header)
            }
        )

        let menuRelations = parsedRelations.otherRelations + parsedRelations.typeRelations
        data.append(
            contentsOf: menuRelations.enumerated().map { index, relation in
                TypeFieldsRelationsData(relation: relation, relationIndex: index, section: .fieldsMenu)
            }
        )

        return data
    }
}
