import BlocksModels
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

    func buildSections(from parsedRelations: ParsedRelations) -> [RelationsSection] {
        let featuredRelations = parsedRelations.featuredRelations
        let otherRelations = parsedRelations.otherRelations
        
        var sections: [RelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: Constants.featuredRelationsSectionId,
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
                    id: Constants.otherRelationsSectionId,
                    title: otherRelationsSectionTitle,
                    relations: otherRelations
                )
            )
        }

        return sections
    }
}

private extension RelationsSectionBuilder {

    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let otherRelationsSectionId = "otherRelationsSectionId"
    }

}
