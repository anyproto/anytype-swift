//
//  ObjectRelationsSectionBuilder.swift
//  Anytype
//
//  Created by Denis Batvinkin on 16.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels
import SwiftProtobuf
import UIKit

final class ObjectRelationsSectionBuilder {

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
        featuredRelations: [ObjectRelationData],
        otherRelations: [ObjectRelationData]
    ) -> [ObjectRelationsSection] {
        var sections: [ObjectRelationsSection] = []

        if featuredRelations.isNotEmpty {
            sections.append(
                ObjectRelationsSection(
                    id: Constants.featuredRelationsSectionId,
                    title: "Featured relations".localized,
                    relations: featuredRelations
                )
            )
        }

        let otherRelationsSectionTitle = otherRelations.isNotEmpty ?
        "Other relations".localized :
        "In this object".localized

        sections.append(
            ObjectRelationsSection(
                id: Constants.otherRelationsSectionId,
                title: otherRelationsSectionTitle,
                relations: otherRelations
            )
        }
        
        return sections
    }

}

private extension ObjectRelationsSectionBuilder {

    enum Constants {
        static let featuredRelationsSectionId = "featuredRelationsSectionId"
        static let otherRelationsSectionId = "otherRelationsSectionId"
    }

}
