final class TypeFieldsRelationsDataBuilder {
    func build(parsedRelations: ParsedRelations) -> [TypeFieldsRelationsData] {
        var sections: [RelationsSection] = []

        if parsedRelations.featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.header,
                    relations: parsedRelations.featuredRelations
                )
            )
        }

        let menuRelations = parsedRelations.otherRelations + parsedRelations.typeRelations
        if menuRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.otherRelationsSectionId,
                    title: Loc.Fields.menu,
                    relations: menuRelations
                )
            )
        }

        return sections.enumerated().flatMap { sectionIndex, section in
            section.relations.enumerated().map { relationIndex, relation in
                TypeFieldsRelationsData(
                    relation: relation,
                    relationIndex: relationIndex,
                    sectionIndex: sectionIndex,
                    sectionTitle: section.title
                )
            }
        }
    }
}
