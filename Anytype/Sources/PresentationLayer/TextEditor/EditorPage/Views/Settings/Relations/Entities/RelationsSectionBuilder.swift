import Services
import SwiftProtobuf
import UIKit

final class RelationsSectionBuilder {

    // MARK: - Private variables

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    // MARK: - Internal functions

    func buildSections(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        let featuredRelations = parsedRelations.featuredRelations
        let otherRelations = parsedRelations.otherRelations
        let typeRelations = parsedRelations.typeRelations
        
        var sections: [RelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: Loc.featuredRelations,
                    relations: featuredRelations
                )
            )
        }

        if otherRelations.isNotEmpty {
            let otherRelationsSectionTitle = featuredRelations.isNotEmpty ?
            Loc.otherRelations :
            Loc.inThisObject

            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.otherRelationsSectionId,
                    title: otherRelationsSectionTitle,
                    relations: otherRelations
                )
            )
        }
        
        if typeRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.typeRelationsSectionId,
                    title: Loc.Relation.From.type(objectTypeName),
                    relations: typeRelations
                )
            )
        }

        return sections
    }
}
