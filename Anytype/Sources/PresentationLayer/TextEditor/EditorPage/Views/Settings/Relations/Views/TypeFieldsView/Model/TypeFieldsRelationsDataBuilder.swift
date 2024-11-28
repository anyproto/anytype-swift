import Services


final class TypeFieldsRelationsDataBuilder {
    func build(relations: [Relation], featured: [Relation]) -> [TypeFieldsRelationsData] {
        var data = [TypeFieldsRelationsData]()

        
        if featured.isNotEmpty {
            data.append(
                contentsOf: featured.enumerated().map { index, relation in
                    TypeFieldsRelationsData(data: .relation(relation), relationIndex: index, section: .header)
                }
            )
        } else {
            data.append(TypeFieldsRelationsData(data: .stub, relationIndex: 0, section: .header))
        }

        if relations.isNotEmpty {
            data.append(
                contentsOf: relations.enumerated().map { index, relation in
                    TypeFieldsRelationsData(data: .relation(relation), relationIndex: index, section: .fieldsMenu)
                }
            )
        } else {
            data.append(TypeFieldsRelationsData(data: .stub, relationIndex: 0, section: .fieldsMenu))
        }

        return data
    }
}
