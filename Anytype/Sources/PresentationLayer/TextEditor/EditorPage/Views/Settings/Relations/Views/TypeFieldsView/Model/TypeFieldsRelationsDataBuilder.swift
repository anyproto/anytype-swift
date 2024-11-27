import Services


final class TypeFieldsRelationsDataBuilder {
    func build(relations: [RelationDetails], featured: [RelationDetails]) -> [TypeFieldsRelationsData] {
        var data = [TypeFieldsRelationsData]()

        data.append(
            contentsOf: featured.enumerated().map { index, relation in
                TypeFieldsRelationsData(relation: relation, relationIndex: index, section: .header)
            }
        )

        data.append(
            contentsOf: relations.enumerated().map { index, relation in
                TypeFieldsRelationsData(relation: relation, relationIndex: index, section: .fieldsMenu)
            }
        )

        return data
    }
}
