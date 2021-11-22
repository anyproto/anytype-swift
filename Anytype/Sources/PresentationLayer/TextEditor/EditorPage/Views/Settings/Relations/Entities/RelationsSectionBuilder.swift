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

    func buildViewModels(
        featuredRelations: [Relation],
        otherRelations: [Relation]
    ) -> [RelationsSection] {
        var sections: [RelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: Constants.featuredRelationsSectionId,
                    title: "Featured relations".localized,
                    relations: featuredRelations
                )
            )
        }

        if otherRelations.isNotEmpty {
            let otherRelationsSectionTitle = featuredRelations.isNotEmpty ?
            "Other relations".localized :
            "In this object".localized

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
