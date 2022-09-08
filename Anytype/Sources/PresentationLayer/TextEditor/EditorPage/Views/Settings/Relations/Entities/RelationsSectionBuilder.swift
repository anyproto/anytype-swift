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
        let featuredRelationValues = parsedRelations.featuredRelationValues
        let otherRelationValues = parsedRelations.otherRelationValues
        
        var sections: [RelationsSection] = []

        if featuredRelationValues.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: Constants.featuredRelationsSectionId,
                    title: Loc.featuredRelations,
                    relationValues: featuredRelationValues
                )
            )
        }

        if otherRelationValues.isNotEmpty {
            let otherRelationsSectionTitle = featuredRelationValues.isNotEmpty ?
            Loc.otherRelations :
            Loc.inThisObject

            sections.append(
                RelationsSection(
                    id: Constants.otherRelationsSectionId,
                    title: otherRelationsSectionTitle,
                    relationValues: otherRelationValues
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
