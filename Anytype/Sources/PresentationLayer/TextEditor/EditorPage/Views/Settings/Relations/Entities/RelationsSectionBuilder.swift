import Services
import SwiftProtobuf
import UIKit
import AnytypeCore

final class RelationsSectionBuilder {
    
    func buildObjectSections(parsedRelations: ParsedRelations) -> [RelationsSection] {
        var sections: [RelationsSection] = []
        
        if parsedRelations.featuredRelations.isNotEmpty || parsedRelations.sidebarRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.featuredRelationsSectionId,
                    title: "",
                    relations: parsedRelations.featuredRelations + parsedRelations.sidebarRelations,
                    isMissingFields: false
                )
            )
        }
        
        if parsedRelations.conflictedRelations.isNotEmpty {
            sections.append(
                RelationsSection(
                    id: RelationsSection.Constants.conflictingRelationsSectionId,
                    title: Loc.Fields.local,
                    relations: parsedRelations.conflictedRelations,
                    isMissingFields: true
                )
            )
        }

        return sections
    }

    func buildSectionsLegacy(from parsedRelations: ParsedRelations, objectTypeName: String) -> [RelationsSection] {
        anytypeAssertionFailure("Not supported in a new API")
        return []
    }
}
